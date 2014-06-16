USE [WebLogDB_EU]
GO
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NagiosOTCSMSFailureCheck_EU]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[NagiosOTCSMSFailureCheck_EU]
GO
 
 
CREATE Procedure [dbo].[NagiosOTCSMSFailureCheck_EU]
As
 
-- 
-- This proc is used to generate a Nagios alert
-- If the sms processing by OTC for make/change/cancels has a complete batch failure.
-- A Nagios alert is generated (Status = 2)
-- 
 
SET        NOCOUNT ON
SET        TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @LastRunDate DATETIME
DECLARE @MaxErrorLogID BIGINT
DECLARE @ErrorCount INT
DECLARE @Status TINYINT
DECLARE @Message VARCHAR(200)

SET @LastRunDate = (select LastRun from WebDB_EU..ScheduledTasks with (nolock) where TaskName = 'ResLogMessaging') 
SET @MaxErrorLogID = (select MAX(ErrorLogID) - 100000000 from WebLogDB_EU..ErrorlogParseVW with (nolock))

select @ErrorCount = COUNT(ErrorLogID) from WebLogDB_EU..ErrorlogParseVW with (nolock) 
where ErrorLogID >= @MaxErrorLogID AND
Instance = 'OTSvcConsole_prod.de' AND 
Type2 = 'OTResLogMessagingFramework' AND 
Type3 = 'Process' AND 
CreateDT > @LastRunDate AND
convert(nvarchar(4000),errmsg) = 'OTResLogMessagingFramework::Process SMS Processing failed.'

SET @Status = CASE
		WHEN @ErrorCount > 0 THEN 2 -- Critical
		ELSE 0 -- Normal
	      END
	      
SET @Message = 'The number of failures since last run is ' + + CAST (@ErrorCount AS VARCHAR(10))  

exec procNagiosActiveResponse @Status, @Message

GO

GRANT EXECUTE ON [dbo].[NagiosOTCSMSFailureCheck_EU] TO [ExecuteOnlyRole] 
GO