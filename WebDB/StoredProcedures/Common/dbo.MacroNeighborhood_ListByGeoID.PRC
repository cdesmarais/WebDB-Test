if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MacroNeighborhood_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MacroNeighborhood_ListByGeoID]
GO

CREATE Procedure dbo.MacroNeighborhood_ListByGeoID
 (
  @GeoID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT DISTINCT 
			mn.MacroID AS MacroNeighborhoodID,
			mn.MacroName AS MacroNeighborhoodName,
			mn.SortOrder AS [SortOrder]
FROM		RestaurantVW r
INNER JOIN	MacroNeighborhoodAVW mn
on			mn.LanguageID = r.LanguageID
INNER JOIN  Neighborhood n
ON			n.MacroID = mn.MacroID 
and			n.neighborhoodid=r.neighborhoodid
WHERE		(mn.metroareaid = @GeoID) 
AND			(r.RestStateID = 1)
ORDER BY	[SortOrder]

GO

GRANT EXECUTE ON [MacroNeighborhood_ListByGeoID] TO ExecuteOnlyRole

GO
