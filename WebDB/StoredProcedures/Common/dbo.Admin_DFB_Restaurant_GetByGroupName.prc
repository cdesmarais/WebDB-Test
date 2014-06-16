if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DFB_Restaurant_GetByGroupName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DFB_Restaurant_GetByGroupName]
GO

CREATE PROCEDURE [dbo].[Admin_DFB_Restaurant_GetByGroupName]
(
	@groupname      nvarchar(50)
)
as

	set transaction isolation level read uncommitted

	select 
		 r.RID		  as 'restaurant_id'
		,r.RName	  as 'name'		
		,m.MetroAreaName 'metroareaname'
	from [dbo].[RestaurantVW] r
	inner join [dbo].[RestaurantToGroup] rtg on r.RID = rtg.RID 
	inner join [dbo].[RestaurantGroup] g on rtg.GID = g.GID
	inner join neighborhoodavw n on r.neighborhoodid = n.neighborhoodid
	and n.languageid = 1
	inner join metroareaavw m on n.metroareaid = m.metroareaid
	and m.languageid = 1
	where g.Groupname = @groupname 
	order by r.RName
	
GO

GRANT EXECUTE ON Admin_DFB_Restaurant_GetByGroupName TO ExecuteOnlyRole
GO

