if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_FoodType_ListWithRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_FoodType_ListWithRestaurants]
GO

CREATE PROCEDURE dbo.Concierge_FoodType_ListWithRestaurants
(
  @RestaurantID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if @RestaurantID = 0
	Begin
	SELECT fts.RID AS RestaurantID
			,ft.FoodType AS FoodTypeName
	FROM		FoodTypes fts
	INNER JOIN	FoodType ft
    ON			fts.FoodTypeID = ft.FoodTypeID 
    INNER JOIN	RestaurantVW r
    ON			fts.RID = r.RID
    AND			r.LanguageID = ft.LanguageID
	ORDER BY fts.RID
	,fts.IsPrimary DESC
	End
if @RestaurantID > 0
	Begin
	SELECT fts.RID AS RestaurantID
		,ft.FoodType AS FoodTypeName
	FROM		FoodTypes fts 
	INNER JOIN	FoodType ft 
	ON			fts.FoodTypeID = ft.FoodTypeID 
	INNER JOIN	RestaurantVW r 
	ON			fts.RID = r.RID
	AND			r.LanguageID = ft.LanguageID
	WHERE fts.RID = @RestaurantID
	ORDER BY fts.IsPrimary DESC
	End

GO

GRANT EXECUTE ON [Concierge_FoodType_ListWithRestaurants] TO ExecuteOnlyRole

GO
