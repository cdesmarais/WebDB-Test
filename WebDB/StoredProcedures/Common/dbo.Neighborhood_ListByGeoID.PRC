if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Neighborhood_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Neighborhood_ListByGeoID]
GO

CREATE Procedure dbo.Neighborhood_ListByGeoID
 (
  @GeoID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT DISTINCT 
			n.neighborhoodid AS NeighborhoodID,
			n.NbhoodName AS NeighborhoodName,
			MacroID as Macro_ID
FROM		NeighborhoodAVW n 
INNER JOIN	RestaurantVW r 
ON			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
WHERE		(n.metroareaid = @GeoID) 
AnD			(r.RestStateID = 1)
ORDER BY	n.NbhoodName

GO

GRANT EXECUTE ON [Neighborhood_ListByGeoID] TO ExecuteOnlyRole

GO
