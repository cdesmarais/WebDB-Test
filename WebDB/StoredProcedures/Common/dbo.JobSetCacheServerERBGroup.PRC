if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSetCacheServerERBGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSetCacheServerERBGroup]
GO

--
-- This proc will ensure that UK ERBs created in NA WebDB are assigned to the correct CS group.
-- The job will be run as a scheduled SQL task,
-- daily or more frequently,
-- until the UK top table migration is complete.
--

CREATE procedure dbo.JobSetCacheServerERBGroup
as

set transaction isolation level read uncommitted

declare @CacheServerERBGroupID int

--------------------------------
-- Set UK ERBs
--------------------------------
select		@CacheServerERBGroupID = CacheServerERBGroupID
from		CacheServerERBGroup cse
inner join	CacheServer cs
on			cse.CacheServerID = cs.CacheServerID
inner join	Server s
on			cs.ServerID = s.ServerID
where		DestWebServer = 'erb.toptable.co.uk'
and			s.Active = 1
order by	CacheServerERBGroupID

if (@CacheServerERBGroupID is not null)
begin
	-- Associate MX with correct CS group
	update			erb 
	set				erb.CacheServerERBGroupID		= @CacheServerERBGroupID
	from			ERBRestaurant				erb
	inner join		Restaurant					r
	on				r.RID						= erb.RID
	left join		CacheServerERBGroupVPNMap cv
	on				erb.ServerIP like cv.IPLike
	where			r.Country					in ('IE', 'UK')
	and				erb.CacheServerERBGroupID		!= @CacheServerERBGroupID
	and				r.IsReachable				= 1
	and				r.RestaurantType			= 'E'
	and				cv.CacheServerERBGroupID is null -- not a VPN overide
end



--------------------------------
-- Set MX ERBs
--------------------------------
set			@CacheServerERBGroupID = null

select		@CacheServerERBGroupID = CacheServerERBGroupID
from		CacheServerERBGroup cse
inner join	CacheServer cs
on			cse.CacheServerID = cs.CacheServerID
inner join	Server s
on			cs.ServerID = s.ServerID
where		DestWebServer = 'erb.opentable.com.mx'
and			s.Active = 1
order by	CacheServerERBGroupID


if (@CacheServerERBGroupID is not null)
begin
	-- Associate MX with correct CS group
	update			erb 
	set				erb.CacheServerERBGroupID		= @CacheServerERBGroupID
	from			ERBRestaurant				erb
	inner join		Restaurant					r
	on				r.RID						= erb.RID
	left join		CacheServerERBGroupVPNMap cv
	on				erb.ServerIP like cv.IPLike
	where			r.Country					in ('mx')
	and				erb.CacheServerERBGroupID		!= @CacheServerERBGroupID
	and				r.IsReachable				= 1
	and				r.RestaurantType			= 'E'
	and				cv.CacheServerERBGroupID is null -- not a VPN overide
end


---------------------------------------
-- Set VPN Groups
---------------------------------------
update		e
set			e.cacheserverERBGroupID = cv.CacheServerERBGroupID
from		ERBRestaurant e
inner join	CacheServerERBGroupVPNMap cv
on			e.ServerIP like cv.IPLike
where		e.cacheserverERBGroupID != cv.CacheServerERBGroupID


GO

GRANT  EXECUTE  ON [dbo].[JobSetCacheServerERBGroup]  TO [ExecuteOnlyRole]
GO

