if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsPromoteCacheServer]') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsPromoteCacheServer]
GO

CREATE PROCEDURE dbo.OpsPromoteCacheServer
(
	@DestServerName nvarchar(100)
)
As

--*************************************************************************************
-- Promotes the cache server -- causing the cache server identified by @DestServerName
-- to take over based on the role of the current default cache server group
--
-- Intendt to be called by Operations when dealing with a DR failover situation
--*************************************************************************************
declare @ServerID int
declare @InternalDNS nvarchar(100)

select  @ServerID = ServerID,
		@InternalDNS = IPAddress
from	Server
where	ServerName = @DestServerName
and		Active = 1

if  @ServerID is null 
begin
	RAISERROR('Cache Server: %s could not be found in server table',16,1, @DestServerName)
	return
end

update	CacheServer 
set		ServerID = @ServerID, InternalDNS = @InternalDNS
where	CacheServerID = (select CacheServerID from CacheServerERBGroup where IsDefaultGroup = 1)

if  @@rowcount = 0
begin
	RAISERROR('No default group found operation FAILED',16,1)
	return
end

GO

GRANT EXECUTE ON [OpsPromoteCacheServer] TO ExecuteOnlyRole

GO

