if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantCuisines]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantCuisines]
GO

CREATE Procedure dbo.DNCacheRestaurantCuisines
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT Distinct
			r.RID as  RestaurantID
			,r.RName AS RestaurantName
			,r.RSName
			,n.MetroAreaID as Metro_Area_ID
			,r.RestStateID as RestStateID
			,r.NeighborhoodID AS NeighborhoodID
			,ft.FoodType AS FoodType
			,ft.FoodType AS FoodTypeName
			,ft.FoodTypeSName AS FoodTypeSName -- Sortable Food Type Name
			,ft.FoodTypeID as FoodTypeID -- Searchable Food Types
			,CASE 
	   		WHEN (r.RestStateID = 1 AND r.IsReachable = 1) 
	   			THEN 1 
	   			ELSE 0 
	 		END AS IsAvailable
			,r.IsReachable as HasHeartbeat
			,MacroID
			,r.Latitude
			,r.Longitude
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
Where		r.RestStateID in (1,2,5,6,7,13) 
and			MacroID is not null
ORDER BY	r.RSName Asc, r.RName Asc
GO


GRANT EXECUTE ON [DNCacheRestaurantCuisines] TO ExecuteOnlyRole

GO
