--Create Stored Proc.
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[svcUserTxnSync_GetEventsToProcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[svcUserTxnSync_GetEventsToProcess]
GO

-- Drop type if it exists
IF EXISTS (SELECT * FROM sys.types WHERE name='UserTxn_FailedUpdates' AND is_table_type=1)
BEGIN
	DROP TYPE [dbo].[UserTxn_FailedUpdates]
END
GO

-- Create type if it does not exist
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='UserTxn_FailedUpdates' AND is_table_type=1)
	CREATE TYPE dbo.UserTxn_FailedUpdates AS TABLE 
	( 
		ResID			INT		NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.UserTxn_FailedUpdates TO ExecuteOnlyRole
GO


CREATE PROCEDURE [dbo].[svcUserTxnSync_GetEventsToProcess]

@CurrentWaterMark			INT,
@UserTxn_FailedUpdates		UserTxn_FailedUpdates READONLY

AS

--Since the table ReservationLog is in the critical Make/Change/Cancel transcation path we are using 
--uncommitted reads to avoid any potential locking issues. There is predicate in the WHERE clause
--to avoid reading uncommitted reservation transactions by eleminating last 1 minute worth of records

--Temp Tables have been used to break it down into small steps because of performance issues seen using multiple joins

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

--Raise an error if watermark doesn't exist				
IF (@CurrentWaterMark IS NULL)
	RAISERROR( 'Invalid value passed as argument for USERTXNSYNC_WATERMARK', 16, 1)

DECLARE		@BatchSize	INT

SELECT		@BatchSize = ValueInt
FROM		ValueLookup
WHERE		LType='DATABASE'
AND			LKey ='UserTxnSync_Batch_Size'

IF	(@BatchSize IS NULL) 
	SET @BatchSize = 500 -- Default Value

-- Pick the high watermark
DECLARE		@MaxLastBatch	INT

SELECT		@MaxLastBatch = MAX(ResLogID)
FROM		ReservationLog 
WHERE		ResLogID >	@CurrentWaterMark
AND			UpdateDT < DATEADD(MINUTE, -1, GETDATE())	-- Since we are doing uncommitted reads; leave out Res events from
OPTION (MAXDOP 1)										-- the past 1 minute period as some may still be uncommitted

--Pick candidate records and do deduplication using ResID
SELECT		TOP (@BatchSize + 100)		-- Another constraint to restrict the total batch size; in case there are too may failed reso updates
			ResID,
			MAX(ResLogID) AS ResLogID

INTO		#tmpResoCandidates

FROM
(
	--Get the set of new/modified resos
	--**Will use PK
	SELECT		TOP (@BatchSize)		-- Restrict the batch size; a large batch on a day like Valentine's day can degrade the performance.
				ResID,
				ResLogID
	FROM		ReservationLog 
	WHERE		ResLogID > @CurrentWaterMark
	AND			ResLogID <= @MaxLastBatch
	AND			RStateID <> 1 -- pick all resos except pending
	ORDER BY	ResLogID ASC -- Sort so that the oldest get picked first when there are more than 500 records.
	
	UNION ALL
	
	--Also grab the set containing the failed updates
	--**Will use Index on ResID
	SELECT		a.ResID,
				a.ResLogID
	FROM		ReservationLog a
	INNER JOIN	@UserTxn_FailedUpdates b
	ON			a.ResID = b.ResID
) AS x

GROUP BY	ResID
ORDER BY	ResLogID ASC

--Join with Reservation table to get the final Reso State
SELECT		CAST(-1 AS BIGINT) AS GlobalPersonID,
			CASE 
				WHEN r.CallerID IS NULL THEN r.CustID 
				ELSE NULL
			END AS CustID,--Use CustID only when Caller isn't present
			r.CallerID,
			r.ResID,
			r.ConfNumber,
			t.ResLogID,			
			r.RID,
			(r.ShiftDate + r.ResTime + 2) AS ShiftDT,
			r.PartySize,
			r.RStateID,
			r.ResPoints AS Points,
			r.PartnerID,
			1 AS IsAnonReso,
			r.LanguageID,
			CASE 
				WHEN r.CallerID IS NOT NULL THEN r.CustID 
				ELSE NULL
			END AS CallerCustID,
			1 AS IsSelfReso
INTO		#tmpUserResos			
FROM		#tmpResoCandidates t
INNER JOIN	Reservation r
ON			t.ResID = r.ResID
--Add the ShiftDate here in future for optimization

--Use Customer Index of GlobalPerson
UPDATE		a
SET			a.GlobalPersonID = b._GlobalPersonID
FROM		#tmpUserResos a
INNER JOIN	GlobalPerson b
ON			a.CustID = b.CustID

--Use Caller Index of GlobalPerson
UPDATE		a
SET			a.GlobalPersonID = b._GlobalPersonID
FROM		#tmpUserResos a
INNER JOIN	GlobalPerson b
ON			a.CallerID = b.CallerID

--Update IsSelfReso=0 for Callers
UPDATE		a
SET			IsSelfReso = 0
FROM		#tmpUserResos a
INNER JOIN	CallerCustomer b
ON			a.CallerCustID = b.CustID
WHERE		b.IsAdmin <> 1

--Update IsAnonReso for Customers
UPDATE		res
SET			IsAnonReso = CASE 
							WHEN c.ConsumerType = 8 THEN 1
							WHEN Dateadd(mi, LocalToServerOffsetMi, ShiftDT) > COALESCE(ConvertDate,c.CreateDate) THEN 0
							ELSE 1
						 END
FROM 		#tmpUserResos res
inner join	RestaurantAVW r
			on	res.RID = r.RID
			and	res.LanguageID = r.LanguageID
inner join 	timezoneVW tz 
			on	r.tzid = tz.tzid
INNER JOIN	Customer c
ON			res.CustID = c.CustID
LEFT JOIN	ConsumertypeConvertlog ctcl 
ON 	 		c.custid = ctcl.custid
AND 		OriginalConsumerTypeID = 8
AND 		ctcl.ConvertDate > c.CreateDate

--Update IsAnonReso for Callers
UPDATE		res
SET			IsAnonReso = CASE 
							WHEN c.ConsumerType = 8 THEN 1							
							WHEN Dateadd(mi, LocalToServerOffsetMi, ShiftDT) > COALESCE(ConvertDate,c.CreateDate) THEN 0
							ELSE 1
						 END
FROM 		#tmpUserResos res
inner join	RestaurantAVW r
			on	res.RID = r.RID
			and	res.LanguageID = r.LanguageID
inner join 	timezoneVW tz 
			on	r.tzid = tz.tzid
INNER JOIN	[Caller] c
ON			res.CallerID = c.CallerID
LEFT JOIN	ConsumertypeConvertlog ctcl 
ON 	 		c.CallerID = ctcl.CallerID
AND 		OriginalConsumerTypeID = 8
AND 		ctcl.ConvertDate > c.CreateDate


--Get the final set by picking the resos that have associated GlobalPersonID and then ordering it by ResLogID
--In the data it's possible that we may have a few orphaned resos which will be dropped here
--The current understanding is that there is an unidentified corner case bug in conversion process which at times
--do not complete the reso update during conversion thereby leaving some resos attached to the old CustID
SELECT		GlobalPersonID,
			ResID,
			ConfNumber,
			ResLogID,			
			RID,
			ShiftDT,
			PartySize,
			RStateID,
			Points,
			PartnerID,
			CAST(IsAnonReso AS BIT) AS IsAnonReso,
			LanguageID,
			CAST(IsSelfReso AS BIT) AS IsSelfReso
FROM		#tmpUserResos
WHERE		GlobalPersonID > 0
ORDER BY	ResLogID

GO


GRANT EXECUTE ON [svcUserTxnSync_GetEventsToProcess] TO ExecuteOnlyRole

GO
