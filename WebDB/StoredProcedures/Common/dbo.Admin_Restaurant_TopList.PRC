if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_TopList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_TopList]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_TopList
(
  @MetroID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


select		ma.MetroAreaName as metro_name,
			r.RID as restaurant_ID,
			r.RName as name,
			isnull(RestaurantTopList.Rank,11) as ListRank,
			ma.toptenlist,
			r.RSName
from		RestaurantVW r
inner join	Neighborhood n 
on			r.neighborhoodid = n.neighborhoodid 
inner join	MetroAreaAVW ma
on			ma.metroareaid = n.metroareaid 
and			ma.LanguageID = r.LanguageID
left join	RestaurantTopList 
on			r.RID = RestaurantTopList.RID 
where		ma.metroareaid = @MetroID
order by	ListRank, r.RSName, r.RName

Return(0)

GO

GRANT EXECUTE ON [Admin_Restaurant_TopList] TO ExecuteOnlyRole

GO
