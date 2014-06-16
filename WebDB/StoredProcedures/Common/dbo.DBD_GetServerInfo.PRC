if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_GetServerInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_GetServerInfo]
GO


CREATE PROCEDURE dbo.DBD_GetServerInfo
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT ServerID, ServerName, WebSite4Version, WebSite31Version, OTService, 
OT3, ServerIP, ChecksumLive, ChecksumExpected,RemotingServer,OTServiceConfigMatch,OT3ConfigMatch,
Active, LastTimeUpdated, Getdate() as NowTime, Getdate() as LastLog
FROM WebServerStatus where active = 1

GO


GRANT EXECUTE ON [DBD_GetServerInfo] TO ExecuteOnlyRole

GO
