

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_GetSearchableCuisine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_GetSearchableCuisine]
go

create procedure [dbo].[Cuisine_GetSearchableCuisine]
(
    @FoodTypeId int
)
as
    --This stored procedure gets all the microcuisine of a cuisine.
    select 
        FoodTypeID
        ,FoodType
    from 
        Foodtype 
    where 
        FoodTypeID 
            in (
                    select 
                        FoodTypeId 
                    from 
                        FoodTypeSearchMap
                    where 
                        searchFoodTypeId = @FoodTypeId
                        and FoodTypeId != @FoodTypeId
                ) 
    order by 
        FoodType asc 

go

grant execute on [Cuisine_GetSearchableCuisine] to ExecuteOnlyRole

go

