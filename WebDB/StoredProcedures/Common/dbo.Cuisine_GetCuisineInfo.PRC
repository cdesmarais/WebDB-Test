

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_GetCuisineInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_GetCuisineInfo]
go

  
create procedure [dbo].[Cuisine_GetCuisineInfo]  
(  
    @FoodTypeId int  
)  
as  
    --This stored proc gets information about the given foodtypeId   
    select    
        ft.FoodTypeId  
        ,ft.FoodType  
        ,ft.FoodTypeSName
        ,case
            when
                ftsm.FoodTypeId is not null
            then 1
            else 0               
         end as IsMacro
    from   
        FoodType ft
    left outer join 
        FoodTypeSearchMap ftsm
        on ftsm.SearchFoodTypeID = ft.FoodTypeID
        and ftsm.FoodTypeId =  ft.FoodTypeID
    where   
        ft.FoodTypeId = @FoodTypeId    
go

grant execute on [Cuisine_GetCuisineInfo] to ExecuteOnlyRole

go

