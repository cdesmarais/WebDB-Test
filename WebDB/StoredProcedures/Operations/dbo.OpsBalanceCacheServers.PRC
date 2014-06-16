if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsBalanceCacheServers]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsBalanceCacheServers]
GO

CREATE PROCEDURE dbo.OpsBalanceCacheServers
As

-- Create Table with Acrive CSGroups
create table #csgroups (
	id int identity(1,1),
	CacheServerERBGroupID int
)

-- Identify CacheServer groups which are:
--		eligible for balancing
--		belong to active and up cache servers
insert	#csgroups 
		select		CacheServerERBGroupID
		from		CacheServerERBGroup csg
		inner join	CacheServer cs
		on			csg.CacheServerID = cs.CacheServerID
		inner join	server s
		on			cs.serverid = s.serverid
		where		GroupName in ('Primary') -- do not include VPN groups and ignore default group 
											-- note default group is on old address space. No ERBs should be permenant members of the default
--		and			_IsUp = 1 -- CS is considered up by website  -- NOTE: this isn't reliable
		and			s.active = 1 -- server is considered active by ops
		


create table #rids (
	id int identity(1,1),
	rid int, 
	CacheServerERBGroupID int
)

-- Identify ERBs that are eligible for rebalancing
-- Must Not be in the exlcusive groups)
-- Must currently be online
insert into #rids
	select		e.RID, 
				e.CacheServerERBGroupID
	from		ERBRestaurant e
	inner join	Restaurant r
	on			e.RID = r.rid
	inner join	CacheServerERBGroup csg
	on			e.CacheServerERBGroupID = csg.CacheServerERBGroupID
	where		r.RestaurantType in ('E', 'G')
	and			IsReachable = 1
	and			GroupName in ('Primary', 'Default Group') -- do not include VPN groups
	order by	e.rid

-- Determine the size of the CS Pool
declare @CacheServers int
select @CacheServers = COUNT(1) from #csgroups

if (@CacheServers < 1)
begin
 Raiserror('No Active Cache Servers',16,1)   
 return
end
-- Rebalance Servers
update		e
set			e.CacheServerERBGroupID = csg.CacheServerERBGroupID
from		ERBRestaurant e
inner join	#rids r
on			e.rid = r.rid
inner join	#csgroups csg
on			csg.id = (r.id % @CacheServers) + 1
where		e.CacheServerERBGroupID != csg.CacheServerERBGroupID



GO

GRANT EXECUTE ON [OpsBalanceCacheServers] TO ExecuteOnlyRole

GO

