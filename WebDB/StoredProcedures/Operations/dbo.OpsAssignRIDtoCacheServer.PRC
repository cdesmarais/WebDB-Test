if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsAssignRIDtoCacheServer]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsAssignRIDtoCacheServer]
GO

CREATE PROCEDURE dbo.OpsAssignRIDtoCacheServer
(
	@IntServerName nvarchar(100),
	@RID	int
)
As

declare @CacheServerERBGroupID int

--*******************************
--** Proc is used to associate an RID to a cache server (used for testing)
--******************************
select		@CacheServerERBGroupID = csg.CacheServerERBGroupID
from		CacheServerERBGroup csg
inner join	CacheServer cs
on			csg.CacheServerID = cs.CacheServerID
inner join	server s
on			cs.serverid = s.serverid
where		GroupName in ('Primary', 'Default Group') -- do not include VPN groups
and			_IsUp = 1 -- CS is considered up by website
and			s.active = 1 -- server is considered active by ops
and			ServerName = @IntServerName


if (@CacheServerERBGroupID is null)
begin
 Raiserror('Could not find Cache Server',16,1)   
 return
end


update		e
set			e.CacheServerERBGroupID = @CacheServerERBGroupID
from		ERBRestaurant e
inner join	Restaurant r
on			e.rid = r.rid
where		e.rid = @RID
and			r.IsReachable = 1

if (@@rowcount = 0)
begin
 Raiserror('Could not find restaurant or restaurant is not currently online',16,1)   
 return
end


GO

GRANT EXECUTE ON [OpsAssignRIDtoCacheServer] TO ExecuteOnlyRole

GO

