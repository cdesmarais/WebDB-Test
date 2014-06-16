if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NeighborhoodListAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NeighborhoodListAll]
GO

CREATE Procedure dbo.NeighborhoodListAll

As
SET NOCOUNT ON


select distinct n.NeighborhoodID,n.LanguageID,n.MetroAreaID,
	   Name = n.NbhoodName, n.MacroID, Latitude = n.NbHoodCenterLat, 
	   Longitude = n.NbHoodCenterLon, LatitudeSpan = n.NbHoodLatSpan,
	   LongitudeSpan = n.NbHoodLonSpan,
	   n.IsGeoCity

	   from RestaurantVW r
	   inner join  NeighborhoodVW n
	   on n.LanguageId = r.LanguageId
	   and r.neighborhoodId = n.neighborhoodId

GO

GRANT EXECUTE ON [NeighborhoodListAll] TO ExecuteOnlyRole

GO