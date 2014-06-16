if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AF_NagiosGetTopTableSynchFailedUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AF_NagiosGetTopTableSynchFailedUpdate]
GO



CREATE Procedure [dbo].[AF_NagiosGetTopTableSynchFailedUpdate]
@CheckID INT
As

SET		NOCOUNT ON
SET		TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Status			TINYINT
DECLARE	@MessageDetails	NVARCHAR(300)
DECLARE @RIDs			VARCHAR(4000) = ''
DECLARE @TblRIDs		TABLE (RID INT)


INSERT	@TblRIDs
SELECT	DISTINCT RID 
FROM	TopTableSync_FailedUpdate 
WHERE	RetryCount > 5
and		CreateDT > GETDATE() - 3


SELECT	@RIDs=@RIDs+ '[' + CAST(RID AS VARCHAR) + ']'
FROM	@TblRIDs

declare @rowcount int
set @rowcount = @@ROWCOUNT

IF (@rowcount > 0)
BEGIN 
	SET @Status = (case when @rowcount > 100 then 2 else 1 end)
	SET @MessageDetails = 'Found failed TopTable updates for ' + CAST(@rowcount AS VARCHAR) + ' RIDs' 
	SET @MessageDetails = substring(@MessageDetails, 1, 100)
END
ELSE
BEGIN
	SET @Status = 0
	SET @MessageDetails = 'No failed updates.'
END
						
EXEC		dbo.AF_NagiosWriteStatus	@CheckID=@CheckID, 
										@Status=@Status, 
										@MessageSummary='TopTable Synch Failed Updates',
										@MessageDetails=@MessageDetails


GO



GRANT EXECUTE ON [AF_NagiosGetTopTableSynchFailedUpdate] TO ExecuteOnlyRole
GRANT EXECUTE ON [AF_NagiosGetTopTableSynchFailedUpdate] TO MonitorUser
GO
