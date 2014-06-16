if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetJustAddedByMetroAreaID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetJustAddedByMetroAreaID]
GO

CREATE PROCEDURE dbo.Restaurant_GetJustAddedByMetroAreaID
(
  @metroid int
)
AS

set transaction isolation level read uncommitted

Select r.RName as Name
		,r.RID as Restaurant_ID
		,n.NbhoodName as NeighborName
		,mn.MacroName as MacroName
from RestaurantVW r
inner join	NeighborhoodAVW n 
on			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
inner join	MacroNeighborhoodAVW mn
on			n.MacroID = mn.MacroID
and			r.LanguageID = mn.LanguageID
inner join	RestaurantJustAdded 
on			r.RID = RestaurantJustAdded.RID
where n.metroareaid = @metroid and JustAdded = 1
order by SortOrder,r.RName

GO

GRANT EXECUTE ON [Restaurant_GetJustAddedByMetroAreaID] TO ExecuteOnlyRole

GO
