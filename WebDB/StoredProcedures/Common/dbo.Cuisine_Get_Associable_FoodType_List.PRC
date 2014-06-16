

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_Get_Associable_FoodType_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_Get_Associable_FoodType_List]
go

create procedure [dbo].[Cuisine_Get_Associable_FoodType_List]
(
    @FoodTypeId int
)
as
    --This stored procedure gets list of the cuisines which can be associated to given foodtype.
    /*  
        Retrieve the LanguageID based on the DB connection  
    */
    declare @LanguageID int  
    exec @LanguageID = procGetDBUserLanguageID          

    select 
        FoodTypeID
        ,FoodType
    from 
        Foodtype 
    where 
        FoodTypeID 
            not in (
                    select 
                        FoodTypeId
                    from 
                        FoodTypeSearchMap
                    where 
                        searchFoodTypeId = @FoodTypeId
                )
        and LanguageID = @LanguageID
    order by 
        FoodType asc  

go

grant execute on [Cuisine_Get_Associable_FoodType_List] to ExecuteOnlyRole

go

