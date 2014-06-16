

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_Add_Associated_FoodType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_Add_Associated_FoodType]
go

create procedure [dbo].[Cuisine_Add_Associated_FoodType]
(
    @FoodTypeId int
    ,@AsscFoodTypeId int --Associated FoodTypeId
)
as
    --This stored procedure add an association of foodtypeid to another foodtypeId.

    insert into FoodTypeSearchMap
    (
        SearchFoodTypeId
        ,FoodTypeId
    )
    values
    (
        @FoodTypeId
        ,@AsscFoodTypeId
    )

go

grant execute on [Cuisine_Add_Associated_FoodType] to ExecuteOnlyRole

go

