-- Drop procedure needs to be before create type (ResLog_ProcessedMessages) because it references that type.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcSavoredSync_LogProcessedEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcSavoredSync_LogProcessedEvents]
GO

-- Drop type if it exists
IF EXISTS (SELECT * FROM sys.types WHERE name='Savored_Notification' AND is_table_type=1)
BEGIN
	DROP TYPE [dbo].[Savored_Notification]
END
GO

-- Create type with ContactInfo if it does not exist
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='Savored_Notification' AND is_table_type=1)
	CREATE TYPE dbo.Savored_Notification AS TABLE 
	( 
		ResLogID		INT		NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.Savored_Notification TO ExecuteOnlyRole
GO

CREATE PROCEDURE	[dbo].[svcSavoredSync_LogProcessedEvents]

@Notifications	Savored_Notification READONLY

AS

SET NOCOUNT ON

DECLARE		@CurrentWaterMark	INT
DECLARE		@NewWatermark	INT

--Check the existing WaterMark
SELECT		@CurrentWaterMark=ValueInt 
FROM		dbo.ValueLookup 
WHERE		LType = 'DATABASE' 
AND			LKey = 'VVSYNC_WATERMARK'


--Find the new watermark
SELECT		@NewWatermark = MAX(ResLogID)
FROM		@Notifications

--Increment by 1 as expected by the reader proc SavoredSync_GetEventsToProcess
SET			@NewWatermark = ISNULL(@NewWatermark,0) + 1

BEGIN TRY
	BEGIN TRAN
	--Update the watermark
	IF (@NewWatermark > ISNULL(@CurrentWaterMark,0))
	 BEGIN
		UPDATE		ValueLookup
		SET			ValueInt = @NewWatermark,
					ValueDT = GETDATE()
		FROM		dbo.ValueLookup 
		WHERE		LType = 'DATABASE' 
		AND			LKey = 'VVSYNC_WATERMARK'
	 END

	--Add new sent notifications to VVSyncLog
	INSERT		VVSyncLog
	SELECT		ResLogID,
				GETDATE() AS CreateDT
	FROM		@Notifications

	COMMIT TRAN
END TRY
BEGIN CATCH
 	ROLLBACK TRAN
	DECLARE @Message NVARCHAR(3000)
	SET @Message = 'Error in proc svcSavoredSync_LogProcessedEvents: [' + ISNULL(ERROR_MESSAGE(),'') + ']'
	RAISERROR(@Message, 16, 1)
END	CATCH



GO

GRANT EXECUTE ON [svcSavoredSync_LogProcessedEvents] TO ExecuteOnlyRole

GO
