if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FoodType_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FoodType_ListByGeoID]
GO

CREATE Procedure dbo.FoodType_ListByGeoID
 (
  @GeoID int
 )
As
--*************************************
--** Returns a list of searchable cuisine types for the region
--*************************************
SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT DISTINCT 
             ft.foodtypeID AS FoodTypeID
            ,ft.FoodType   AS FoodTypeName
FROM		RestaurantVW r
INNER JOIN	Neighborhood n 
ON			r.NeighborhoodID = n.NeighborhoodID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID
INNER JOIN	FoodTypeSearchMap cm
ON			cm.FoodTypeID = fts.FoodTypeID
INNER JOIN  FoodType ft
ON          ft.FoodTypeID   = cm.SearchFoodTypeID 
and			ft.LanguageID = r.LanguageID
WHERE       (n.metroareaid   = @GeoID) 
AND         (r.RestStateID in (1,5,6,13))
ORDER BY	ft.FoodType


GO


GRANT EXECUTE ON [FoodType_ListByGeoID] TO ExecuteOnlyRole

GO
