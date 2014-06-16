if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllRestaurantCuisines]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllRestaurantCuisines]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllRestaurantCuisines
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT distinct
			r.RID as  RestaurantID
			,ft.FoodType AS FoodType
			,ft.FoodTypeSName AS FoodTypeSName -- Sortable Food Type Name
			,ft.FoodTypeID as FoodTypeID -- Searchable Food Types
			,ft.GUID
			,r.LanguageID
FROM		RestaurantAVW r
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID
INNER JOIN	FoodTypeSearchMap cm
ON			cm.FoodTypeID = fts.FoodTypeID
INNER JOIN  FoodType ft
ON          ft.FoodTypeID   = cm.SearchFoodTypeID 
and			ft.LanguageID = r.LanguageID

GO


GRANT EXECUTE ON [RestaurantImporter_GetAllRestaurantCuisines] TO ExecuteOnlyRole

GO
