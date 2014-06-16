if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllFoodTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllFoodTypes]
GO

CREATE procedure [dbo].[Admin_CacheAllFoodTypes] 
AS
SET NOCOUNT ON


    SELECT foodtypeID AS FoodTypeID,
		FoodType as Value, 
		LanguageID
	FROM FoodType 
	Order by FoodType


GO

GRANT EXECUTE ON [Admin_CacheAllFoodTypes] TO ExecuteOnlyRole
GO