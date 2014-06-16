if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsUpdateServerLoadbalancerStatus]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsUpdateServerLoadbalancerStatus]
GO

CREATE PROCEDURE dbo.OpsUpdateServerLoadbalancerStatus
(
	@ServerName nvarchar(100), 
	@AcceptsTraffic bit
)
  
As

declare @LBStatusCode int

if (@AcceptsTraffic = 0) 
	set @LBStatusCode = 0	-- LBStatusCode = 0 = OTWEB_OFF
else
	set @LBStatusCode = 1	-- LBStatusCode = 1 = OTWEB_ON
	
update	[Server]
set		AcceptsTraffic = @AcceptsTraffic, 
		LBStatusCode = @LBStatusCode
where	ServerName = @ServerName


--****************************
--** The following is legacy and is needed to support the transtion from our old table webserverstatus to our new table Server
--** Remove the following after 8/1/2008
--****************************
update	webserverstatus
set		AcceptsTraffic = @AcceptsTraffic
where	ServerName = @ServerName
		
GO

GRANT EXECUTE ON [OpsUpdateServerLoadbalancerStatus] TO ExecuteOnlyRole
GO

