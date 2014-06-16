--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcTopTableSync_GetEventsToProcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcTopTableSync_GetEventsToProcess]
GO

CREATE PROCEDURE [dbo].[svcTopTableSync_GetEventsToProcess]
AS
--Since the table ReservationLog is in the critical Make/Change/Cancel transcation path using 
--uncommitted reads to avoid any potential locking issues. There is predicate in the WHERE clause
--to avoid reading uncommitted data by eleminating last 1 minute worth of records

--Temp Tables have been used to break it down into small steps because of performance issues seen using multiple joins

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE		@CurrentWaterMark	INT

SELECT		@CurrentWaterMark=ValueInt 
FROM		dbo.ValueLookup 
WHERE		LType = 'DATABASE' 
AND			LKey = 'TOPTABLESYNC_WATERMARK'

--Raise an error if watermark doesn't exist				
IF (@CurrentWaterMark IS NULL)
	RAISERROR( 'Invalid value found/missing Key [TOPTABLESYNC_WATERMARK] in ValueLookup', 16, 1)


-- Pick the high watermark
DECLARE		@MaxLastBatch	INT

SELECT		@MaxLastBatch = MAX(ResLogID)
FROM		ReservationLog 
WHERE		ResLogID >	@CurrentWaterMark
AND			UpdateDT < DATEADD(MINUTE, -1, GETDATE())	-- Since we are doing uncommitted reads; leave out Res events from
														-- the past 1 minute period as some may still be uncommitted
option (maxdop 1)

--Filter out the consumer made updates and pick only TopTable related changes
SELECT		ResID,
			ResLogID
INTO		#tmpResoupdatesTTNonConsumer
FROM		ReservationLog 
WHERE		ResLogID > @CurrentWaterMark
AND			ResLogID <= @MaxLastBatch

AND			(-- This proc is used by the OTService to keep TopTable and OpenTable Reso's
			--	in sync. All updats done by consumers through TopTable's website get reflected
			--	in both TT as well as OT databases. But any back-end updates done on OT side will
			--	need to be relayed back to TopTable. So this proc should only pick the updates that 
			--	are non-consumer updates e.g. Reso updates done from CHARM/OTConnect/SQL Jobs. 
			--	Filtering out the Host with key word "-web-" will ensure that all updates coming from the 
			--	WebServers are rejected and including the updates done by "WebuserRegion" (which is never
			--	used by WebSite) will ensure that all the non-webserver initiated updates are captured.
				Host NOT LIKE '%-WEB-%' 
				OR
				DBUser = 'WebUserRegion'
			)
AND			PartnerID IN	( -- All reso updates from TopTable are made using special PartnerID's
							--	Only pick resos with topTable PartnerID's
								SELECT		ValueID 
								FROM		ValueLookupMaster a
								INNER JOIN	ValueLookupIDList b
								ON			a.LookupID=b.LookupID
								WHERE		a.[Type] = 'DATABASE'
								AND			a.[Key] = 'TOPTABLE_PARTNERID_LIST'	
							) 


--IF the set has no TopTable resosupdates but has other changes then update the LastSent table, 
IF (@@ROWCOUNT = 0 AND @MaxLastBatch > 0)
 BEGIN
	UPDATE		ValueLookup
	SET			ValueInt = @MaxLastBatch
	WHERE		LType = 'DATABASE' 
	AND			LKey = 'TOPTABLESYNC_WATERMARK'
 END


-- Do deduplication
SELECT		ResID,
			MAX(ResLogID) AS ResLogID

INTO		#tmpResoUpdates

FROM
(
	SELECT		ResID,
				ResLogID
	FROM		#tmpResoupdatesTTNonConsumer
	
	UNION ALL
	
	--Also grab the set containing the failed updates
	SELECT		a.ResID,
				a.ResLogID
	FROM		ReservationLog a
	INNER JOIN	TopTableSync_FailedUpdate b
	ON			a.ResLogID = b.ResLogID
	WHERE       CreateDT > GETDATE() - 5   -- don't bother with records that have been failed for more than 5 days
) AS x

GROUP BY	ResID


--Join with Reservation table to get the final Result Set
SELECT		t.ResLogID,
			r.RID,
			r.ConfNumber,
			r.PartySize,
			(r.ShiftDate + r.ResTime + 2) AS ReservationDT,
			r.RStateID AS ReservationState,
			GETUTCDATE() AS TimeStamp_UTC
FROM		#tmpResoUpdates t
INNER JOIN	Reservation r
ON			t.ResID = r.ResID


GO


GRANT EXECUTE ON [svcTopTableSync_GetEventsToProcess] TO ExecuteOnlyRole

GO
