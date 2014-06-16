if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodType_ListByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodType_ListByRestaurant]
GO


CREATE PROCEDURE dbo.Admin_FoodType_ListByRestaurant
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--************************
--** Retrieve the LanguageID based on the DB connection
--** Error Out if no language Found
--************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

SELECT     fts.foodtypeID AS FoodTypeID
          ,fts.IsPrimary   AS IsPrimary
          ,ft.FoodType
FROM       FoodTypes fts
INNER JOIN FoodType ft
ON         fts.foodtypeID  = ft.foodtypeID
WHERE     (fts.RID = @RestaurantID)
		and LanguageID = @LanguageID
ORDER BY fts.FTRank

GO

GRANT EXECUTE ON [Admin_FoodType_ListByRestaurant] TO ExecuteOnlyRole

GO
