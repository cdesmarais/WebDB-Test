if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNListAllRestaurantGroups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNListAllRestaurantGroups]
GO

CREATE PROCEDURE dbo.DNListAllRestaurantGroups 

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*build 10/22/2003 for QA testing purposes*/

select		r.rid
		,r.rname
		,m.metroareaname
		,g.groupname
from		restaurantVW r
inner join	Neighborhood n
on		r.neighborhoodid = n.neighborhoodid
inner join	MetroAreaLocal m
on		n.metroareaid = m.metroareaid
and		r.LanguageID = m.LanguageID
inner join	restauranttogroup rg
on		r.rid = rg.rid
inner join	restaurantgroup g
on		rg.gid = g.gid
order by	m.metroareaname,r.rname
GO

GRANT EXECUTE ON [DNListAllRestaurantGroups] TO ExecuteOnlyRole

GO
