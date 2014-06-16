--Create Stored Proc.
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[svcReservationPublisher_GetReservationLogUpdates]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[svcReservationPublisher_GetReservationLogUpdates]
GO

CREATE PROCEDURE [dbo].[svcReservationPublisher_GetReservationLogUpdates]
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE @errormessage nvarchar(500)

IF (NOT EXISTS (SELECT ValueInt FROM dbo.ValueLookup WHERE LKey = 'RESOPUBLISHER_SYNC_WATERMARK' AND LTYPE='SERVICE'))
BEGIN
	SET @errormessage = 
		'Missing RESOPUBLISHER_SYNC_WATERMARK from ValueLookup; please run ReservationPublisherSetup.sql before running svcReservationPublisher_GetReservationLogUpdates proc' 
	RAISERROR(@errormessage, 16, 1)
    RETURN -1
END

-------------------------------------------
-- Watermark initialization
-------------------------------------------

-- Get current high water mark from ValueLookup
-- We will process resos above this value
DECLARE @CurrentWaterMark INT
SELECT @CurrentWaterMark = ValueInt
FROM dbo.ValueLookup 
WHERE LKey = 'RESOPUBLISHER_SYNC_WATERMARK' AND LTYPE='SERVICE'

-- Get next high water mark from Res Log
-- We will process resos equal or below this value
-- Since we are doing uncommitted read; Leaving a 1 minute gap to exclude the transactions that might not have been committed yet
DECLARE @NextWaterMark INT
SELECT  @NextWaterMark = MAX(ResLogID) 
FROM dbo.ReservationLog 
WHERE	ResLogID >= @CurrentWaterMark AND UpdateDT < DATEADD(SECOND, -10, GETDATE())

DECLARE @Offset int
SET @Offset = DATEDIFF(second, GETDATE(), GETUTCDATE())

-----------------------------------------------------------------------------------------
-- Join data with larger table: Reservation, Restaurant, RestaurantLocal, GlobalPerson, Language
-----------------------------------------------------------------------------------------
SELECT		resoLog.ResID 									resId,
			resoLog.ResLogID								sequenceId,
			resoLog.RStateID 								rState,
			resoLog.RID 									rid,
			COALESCE(restLocal.RName, '')					restaurantName,
			reso.ConfNumber									confNumber,
			CONVERT(BIGINT, ISNULL(gp._GlobalPersonID, 0))	gpId,
			CONVERT(NVARCHAR, resoLog.ShiftDT, 120) 		shiftDT,
			resoLog.PartySize								partySize,
			rest.TZID										tzId,
			lang.LanguageCode								languageCode,
			CONVERT(CHAR(24), DATEADD(second, @Offset, resoLog.UpdateDT), 127)
															modificationDt
FROM		dbo.ReservationLog		resoLog

INNER JOIN	dbo.Reservation			reso
ON			reso.ResID				= resoLog.ResID

INNER JOIN  dbo.Restaurant 			rest
ON			rest.RID 				= resoLog.RID

LEFT JOIN 	dbo.RestaurantLocal 	restLocal
ON 			restLocal.RID			= reso.RID
AND			restLocal.LanguageID	= reso.LanguageID

INNER JOIN  dbo.[Language]			lang
ON			lang.LanguageId 		= reso.LanguageID
				
LEFT JOIN   dbo.GlobalPerson        gp
ON          gp.CustID      			= resoLog.CustID

WHERE		resoLog.ResLogID		> @CurrentWaterMark			-- above current watermark
AND			resoLog.ResLogID		<= @NextWaterMark			-- at next watermark
AND			reso.ShiftDate			>= (GETDATE()- 30)			-- optimization for reservation partition

ORDER BY	resoLog.ResLogId
GO

GRANT EXECUTE ON [svcReservationPublisher_GetReservationLogUpdates] TO ExecuteOnlyRole
GO
