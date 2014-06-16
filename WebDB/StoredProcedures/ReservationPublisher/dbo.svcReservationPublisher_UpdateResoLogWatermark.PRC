--Create Stored Proc
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[svcReservationPublisher_UpdateResoLogWatermark]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[svcReservationPublisher_UpdateResoLogWatermark]
GO

CREATE PROCEDURE [dbo].[svcReservationPublisher_UpdateResoLogWatermark]
	( @NextWaterMark	int)
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE @errormessage nvarchar(500)

IF NOT EXISTS(SELECT 1 FROM dbo.ReservationLog WHERE ResLogID = @NextWaterMark)
BEGIN
	SET @errormessage = 
		'Attempt to set invalid watermark in svcReservationPublisher_UpdateResoLogWatermark proc' 
	RAISERROR(@errormessage, 16, 1)
    RETURN -1
END

-------------------------------------------
-- Set next Water Mark
-------------------------------------------
UPDATE dbo.ValueLookup
	SET [ValueInt] = @NextWaterMark
WHERE LKey = 'RESOPUBLISHER_SYNC_WATERMARK' AND LTYPE='SERVICE' AND ValueInt <> @NextWaterMark
GO

GRANT EXECUTE ON [svcReservationPublisher_UpdateResoLogWatermark] TO ExecuteOnlyRole
GO

