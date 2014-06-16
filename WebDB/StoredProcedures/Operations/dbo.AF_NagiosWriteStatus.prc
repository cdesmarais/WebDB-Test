if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AF_NagiosWriteStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AF_NagiosWriteStatus]
GO

CREATE PROCEDURE dbo.AF_NagiosWriteStatus
 @CheckID			INT,
 @Status			INT,
 @MessageSummary	NVARCHAR(100),
 @MessageDetails	NVARCHAR(300)
 
AS

SET NOCOUNT ON

--**************************************************************
--Alerting framework
--This proc writes the status of a process for Nagios check to
-- a table in DBAdmin Database
--**************************************************************

UPDATE		DBAdmin.dbo.AF_Status
SET			[Status] = @Status,
			MessageSummary = @MessageSummary,
			MessageDetails = @MessageDetails,
			LastUpdate = GETDATE()
WHERE		CheckID = @CheckID

IF (@@ROWCOUNT = 0)
BEGIN
	INSERT		DBAdmin.dbo.AF_Status
				(CheckID, [Status], MessageSummary, MessageDetails, LastUpdate)
	VALUES		(@CheckID, @Status, @MessageSummary, @MessageDetails, GETDATE())

END

GO

GRANT EXECUTE ON [AF_NagiosWriteStatus] TO ExecuteOnlyRole
GRANT EXECUTE ON [AF_NagiosWriteStatus] TO MonitorUser

GO

