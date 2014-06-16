if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobPostProcessROMSRestaurantGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobPostProcessROMSRestaurantGroup]
GO


CREATE PROCEDURE dbo.JobPostProcessROMSRestaurantGroup

As

set transaction ISOLATION LEVEL read UNCOMMITTED

insert into	RestaurantGroup(GroupName, GID)
values ('Ruth''s Chris Steak House Consolidated', -1)

declare		@GID as int
select		@GID=GID 
from		restaurantGroup
where		GID = -1

insert into	RestaurantToGroup
select		distinct R.RID, 
			@GID as GID
from		restaurant R
inner join 
	(select	RTG.RID,
			RTG.GID, 
			RG.GroupName
	from	dbo.RestaurantToGroup RTG
	inner join dbo.RestaurantGroup RG
	on		RTG.GID = RG.GID
	where	RG.GroupName like '%Ruth''s Chris%'
	)x
on	R.RID = x.RID
union
 (select	R.RID,
			@GID as GID 
  from		restaurantvw R 
  where		R.Rname like '%Ruth''s Chris%'
 )
 
 Go
  
GRANT EXECUTE ON [JobPostProcessROMSRestaurantGroup] TO ExecuteOnlyRole

GO
