-- Drop procedure needs to be before create type (ResLog_ProcessedMessages) because it references that type.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcTopTableSync_LogProcessedEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcTopTableSync_LogProcessedEvents]
GO

-- Drop type if it exists
IF EXISTS (SELECT * FROM sys.types WHERE name='TopTable_ResoUpdates' AND is_table_type=1)
BEGIN
	DROP TYPE [dbo].[TopTable_ResoUpdates]
END
GO

-- Create type with ContactInfo if it does not exist
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='TopTable_ResoUpdates' AND is_table_type=1)
	CREATE TYPE dbo.TopTable_ResoUpdates AS TABLE 
	( 
		RID				INT		NOT NULL,
		ConfNumber		INT		NOT NULL,
		ResLogID		INT		NOT NULL,
		IsSuccessful	BIT		NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.TopTable_ResoUpdates TO ExecuteOnlyRole
GO

CREATE PROCEDURE	[dbo].[svcTopTableSync_LogProcessedEvents]

@ProcessedResoUpdates	TopTable_ResoUpdates READONLY

AS

SET NOCOUNT ON

DECLARE		@CurrentWaterMark	INT
DECLARE		@NewWatermark	INT

--Check the existing WaterMark
SELECT		@CurrentWaterMark=ValueInt 
FROM		dbo.ValueLookup 
WHERE		LType = 'DATABASE' 
AND			LKey = 'TOPTABLESYNC_WATERMARK'


--Find the new watermark
SELECT		@NewWatermark = MAX(ResLogID)
FROM		@ProcessedResoUpdates
WHERE		IsSuccessful = 1

BEGIN TRY
	BEGIN TRAN
	--Insert the ResLogID for the successfully sent message to the ResLog_SentMessage table
	IF (@NewWatermark > ISNULL(@CurrentWaterMark,0))
	 BEGIN
		UPDATE		ValueLookup
		SET			ValueInt = @NewWatermark,
					ValueDT = GETDATE()
		FROM		dbo.ValueLookup 
		WHERE		LType = 'DATABASE' 
		AND			LKey = 'TOPTABLESYNC_WATERMARK'
	 END

	--Update Count for existing failed resoupdates
	UPDATE		f
	SET			RetryCount += 1
	FROM		dbo.TopTableSync_FailedUpdate f
	INNER JOIN	@ProcessedResoUpdates p
	ON			f.RID = p.RID
	AND			f.ConfNumber = p.ConfNumber
	AND			0 = p.IsSuccessful

	--Add new failed updates to TopTableSync_FailedUpdate
	INSERT		TopTableSync_FailedUpdate
	SELECT		p.RID,
				p.ConfNumber,
				p.ResLogID,
				1 AS RetryCount,
				GETDATE() AS CreateDT
	FROM		@ProcessedResoUpdates p
	LEFT JOIN	dbo.TopTableSync_FailedUpdate f
	ON			f.RID = p.RID
	AND			f.ConfNumber = p.ConfNumber
	WHERE		f.ResLogID IS NULL
	AND			p.IsSuccessful = 0

	--Remove from the TopTableSync_FailedUpdate table the ones that have succeeded now
	DELETE		f
	FROM		dbo.TopTableSync_FailedUpdate f
	INNER JOIN	@ProcessedResoUpdates p
	ON			f.RID = p.RID
	AND			f.ConfNumber = p.ConfNumber
	WHERE		p.IsSuccessful = 1
	
	COMMIT TRAN
END TRY
BEGIN CATCH
 	ROLLBACK TRAN
	DECLARE @Message NVARCHAR(3000)
	SET @Message = 'Error in proc svcTopTableSync_LogProcessedEvents: [' + ISNULL(ERROR_MESSAGE(),'') + ']'
	RAISERROR(@Message, 16, 1)
END	CATCH



GO

GRANT EXECUTE ON [svcTopTableSync_LogProcessedEvents] TO ExecuteOnlyRole

GO
