if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DFB_Restaurant_GetByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DFB_Restaurant_GetByRID]
GO

CREATE PROCEDURE [dbo].[Admin_DFB_Restaurant_GetByRID]
(
	@rid       int
)
as

	set transaction isolation level read uncommitted

	select 
		 r.RID	'restaurant_id'
		,r.RName	'name'		
		,m.MetroAreaName 'metroareaname'
	from [dbo].[RestaurantVW] r
	inner join neighborhoodavw n on r.neighborhoodid = n.neighborhoodid
	and n.languageid = 1
	inner join metroareaavw m on n.metroareaid = m.metroareaid
	and m.languageid = 1
	where r.RID = @rid
	
GO

GRANT EXECUTE ON Admin_DFB_Restaurant_GetByRID TO ExecuteOnlyRole
GO

