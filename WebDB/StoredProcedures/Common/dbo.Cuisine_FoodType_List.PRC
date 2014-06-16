

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_FoodType_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_FoodType_List]
go

create procedure [dbo].[Cuisine_FoodType_List]

as
    --This stored procedure gets the cuisine list based on the languageID.
    
    /*  
        Retrieve the LanguageID based on the DB connection  
    */
    declare @LanguageID int  
    exec @LanguageID = procGetDBUserLanguageID      
    
    select 
        ft.FoodTypeID
        ,count(fts.RID) as RestCount --Restaurant count
        ,ft.FoodType
        ,case   --If FoodTypeId exisits in FoodtypeSearchMap then searchable otherwise not searchable.
            when 
                ft.FoodTypeID 
                in (
                        select 
                            FoodTypeID 
                        from 
                            foodtypeSearchMap ftsm
                        where 
                            ftsm.SearchFoodTypeID = ft.FoodTypeID
                    ) 
            then 1 --1= searchable
            else 0 --0 = unsearchable
         end as Searchable
    from 
        FoodType ft
        left outer join FoodTypes fts
        on ft.FoodTypeID = fts.FoodTypeID
    where
        ft.LanguageID = @LanguageID   --languageid = user languageid
           
    group by 
        ft.foodtypeID
        ,ft.FoodType
    order by
        ft.FoodType asc
go

grant execute on [Cuisine_FoodType_List] to ExecuteOnlyRole

go

