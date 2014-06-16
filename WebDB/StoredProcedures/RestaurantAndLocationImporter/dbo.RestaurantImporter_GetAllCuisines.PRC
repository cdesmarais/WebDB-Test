if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllCuisines]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllCuisines]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllCuisines
As

	set transaction isolation level read uncommitted
	set nocount on

select 
    [GUID]
	,FoodTypeId
	,FoodType
	,LanguageID 
from FoodType  

GO

GRANT EXECUTE ON [RestaurantImporter_GetAllCuisines] TO ExecuteOnlyRole

GO