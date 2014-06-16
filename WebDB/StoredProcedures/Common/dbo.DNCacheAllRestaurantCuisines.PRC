if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheAllRestaurantCuisines]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheAllRestaurantCuisines]
GO

CREATE Procedure dbo.DNCacheAllRestaurantCuisines
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT Distinct  
    n.MetroAreaID as MetroAreaID
   ,ft.FoodTypeID as FoodTypeID   
   ,ft.FoodType AS FoodTypeName  
   ,ft.FoodTypeSName AS FoodTypeSName  
   ,cm.SearchFoodTypeID  
 FROM  RestaurantVW r  
 INNER JOIN NeighborhoodAVW n   
 ON   r.NeighborhoodID = n.NeighborhoodID  
 and   r.LanguageID = n.LanguageID  
 INNER JOIN FoodTypes fts  
 ON   r.RID = fts.RID   
 AND   isPrimary = 1  
 INNER JOIN CusineToLeastSpecificMacroVW cm  
 ON   cm.FoodTypeID = fts.FoodTypeID  
 INNER JOIN FoodType ft  
 ON   fts.FoodTypeID = ft.FoodTypeID   
 AND   ft.LanguageID = r.LanguageID  
 INNER JOIN Language l  
 on   l.LanguageID = r.LanguageID  
 Where r.RestStateID not in (4)
 ORDER BY ft.FoodType

GO

GRANT EXECUTE ON [DNCacheAllRestaurantCuisines] TO ExecuteOnlyRole

GO