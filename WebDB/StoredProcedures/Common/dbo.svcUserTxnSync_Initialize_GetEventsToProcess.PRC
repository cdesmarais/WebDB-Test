--Create Stored Proc.
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[svcUserTxnSync_Initialize_GetEventsToProcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[svcUserTxnSync_Initialize_GetEventsToProcess]
GO

-- Drop type if it exists
IF EXISTS (SELECT * FROM sys.types WHERE name='UserTxn_Initialize_FailedUpdates' AND is_table_type=1)
BEGIN
	DROP TYPE [dbo].[UserTxn_Initialize_FailedUpdates]
END
GO

-- Create type with ContactInfo if it does not exist
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='UserTxn_Initialize_FailedUpdates' AND is_table_type=1)
	CREATE TYPE dbo.[UserTxn_Initialize_FailedUpdates] AS TABLE 
	( 
		GlobalPersonID			BIGINT		NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.[UserTxn_Initialize_FailedUpdates] TO ExecuteOnlyRole
GO


CREATE PROCEDURE [dbo].[svcUserTxnSync_Initialize_GetEventsToProcess]

@CurrentWaterMark					BIGINT,
@Upperbound							BIGINT,
@UserTxn_Initialize_FailedUpdates	UserTxn_Initialize_FailedUpdates READONLY

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

--Raise an error if watermark doesn't exist				
IF (@CurrentWaterMark IS NULL)
	RAISERROR( 'Invalid value passed as argument for USERTXNSYNC_INITIALIZE_WATERMARK', 16, 1)

DECLARE		@BatchSize	INT

SELECT		@BatchSize = ValueInt
FROM		ValueLookup
WHERE		LType='DATABASE'
AND			LKey ='UserTxnInit_Batch_Size'

IF	(@BatchSize IS NULL) 
	SET @BatchSize = 3000 -- Default Value

--Extracting the set into a Temp table to avoid joining big tables for performance reasons
SELECT		TOP (@BatchSize + 100) -- Another restriction in case there are too many failed ones.
			GlobalPersonID,
			CustID,
			CallerID

INTO		#tmpUsers

FROM
(
	SELECT		TOP (@BatchSize) -- Restrict the batch size
				_GlobalPersonID AS GlobalPersonID,
				CustID,
				CallerID
	FROM		GlobalPerson
	WHERE		_GlobalPersonID >	@CurrentWaterMark
	AND			_GlobalPersonID <=	@Upperbound
	AND			_GlobalPersonID NOT IN (
				140018820904,140022681064,140029322014,150020494145,150032895145,150035946395,160011233796,160018922836,
				160039072386,170003382507,170004204787,170004620267,170014456877,170015443287,170016225767,170036090317,		
				170038098327,180005684608,180011279378,180031735048,190014241139,190036271079,190039034259,
				150013965225,160028178856,
				130038940923,310000114281,320001081202,330000280793,350000066745,360005928116,360000764556)--Excluding users with resocount > 10,000.
	ORDER BY	GlobalPersonID
	
	UNION
	
	SELECT		a.GlobalPersonID,
				b.CustID,
				b.CallerID
	FROM		@UserTxn_Initialize_FailedUpdates a
	INNER JOIN	GlobalPerson b
	ON			a.GlobalPersonID = b._GlobalPersonID
) a

--Join with Reservation table to get the Reservation data
SELECT		u.GlobalPersonID,
			u.CustID,
			u.CallerID,
			r.ResID,
			r.ConfNumber,
			r.RID,
			(r.ShiftDate + r.ResTime + 2) AS ShiftDT,
			r.PartySize,
			r.RStateID,
			r.ResPoints AS Points,
			r.LanguageID,
			r.PartnerID,
			1 AS IsAnonReso,
			CASE 
				WHEN r.CallerID IS NOT NULL THEN r.CustID 
				ELSE NULL
			END AS CallerCustID,
			1 AS IsSelfReso
INTO		#tmpUserResos			
FROM		Reservation r
INNER JOIN	#tmpUsers u
ON			r.CustID = u.CustID
WHERE		r.RStateID <> 1 -- pick all resos except pending

--Join with Reservation table to get the Reservation data
INSERT INTO	#tmpUserResos
SELECT		u.GlobalPersonID,
			u.CustID,
			u.CallerID,
			r.ResID,
			r.ConfNumber,
			r.RID,
			(r.ShiftDate + r.ResTime + 2) AS ShiftDT,
			r.PartySize,
			r.RStateID,
			r.ResPoints AS Points,
			r.LanguageID,
			r.PartnerID,
			1 AS IsAnonReso,
			CASE 
				WHEN r.CallerID IS NOT NULL THEN r.CustID 
				ELSE NULL
			END AS CallerCustID,
			1 AS IsSelfReso
FROM		Reservation r
INNER JOIN	#tmpUsers u
ON			r.CallerID = u.CallerID
WHERE		r.RStateID <> 1 -- pick all resos except pending

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
INNER JOIN	RestaurantAVW r
ON			res.RID = r.RID
AND			res.LanguageID = r.LanguageID
INNER JOIN 	timezoneVW tz 
ON			r.tzid = tz.tzid
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
INNER JOIN	RestaurantAVW r
ON			res.RID = r.RID
AND			res.LanguageID = r.LanguageID
INNER JOIN 	timezoneVW tz 
ON			r.tzid = tz.tzid
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
SELECT		CAST(GlobalPersonID AS BIGINT) AS GlobalPersonID,
			ResID,
			ConfNumber,
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
ORDER BY	GlobalPersonID
GO


GRANT EXECUTE ON [svcUserTxnSync_Initialize_GetEventsToProcess] TO ExecuteOnlyRole
GO
