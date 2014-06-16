if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DFB_Restaurant_SearchByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DFB_Restaurant_SearchByName]
GO

CREATE PROCEDURE [dbo].[Admin_DFB_Restaurant_SearchByName]
(
	@name       nvarchar(50)
)
as

	set transaction isolation level read uncommitted

	select top 150 -- We use top 150 here because we expect no more than about 120 restaurants with the same name, ie., "Ruth's Chris" or "Morton's"
		 r.rid	'restaurant_id'
		,r.rname	'name'		
		,m.metroareaname 'metroareaname'
	from dbo.restaurantvw r
	inner join neighborhoodavw n on r.neighborhoodid = n.neighborhoodid
	and n.languageid = 1
	inner join metroareaavw m on n.metroareaid = m.metroareaid
	and m.languageid = 1
	where r.rname like '%' + @name + '%'
	order by r.rname
	
GO

GRANT EXECUTE ON Admin_DFB_Restaurant_SearchByName TO ExecuteOnlyRole
GO

