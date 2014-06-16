

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_Delete_Associated_FoodType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_Delete_Associated_FoodType]
go

create procedure [dbo].[Cuisine_Delete_Associated_FoodType]
(
    @FoodTypeId int
    ,@AsscFoodTypeId int --Associated FoodTypeId
)
as
    --This stored procedure delete association of foodtypeid with given foodtypeId.

    delete from
        FoodTypeSearchMap
    where
        FoodTypeId = @AsscFoodTypeId
        and SearchFoodTypeId = @FoodTypeId    

go

grant execute on [Cuisine_Delete_Associated_FoodType] to ExecuteOnlyRole

go

