

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_FoodType_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_FoodType_Add]
go

create procedure [dbo].[Cuisine_FoodType_Add]
(
    @FoodType nvarchar(200)
    ,@FoodTypeSName nvarchar(200)
    ,@IsMacro bit
)
as
    --This stored procedure adds a foodtype. It inserts record in FoodType and FoodTypeSearchMap in case of Macro
    -- and insert only in FoodType in case of Micro.
    declare @LanguageID int
    declare @FoodTypeId int

    begin transaction trans
    
    -- Get language id based on DB connection
    exec @LanguageID = procGetDBUserLanguageID
    
    if (@@error <> 0)
	    goto error

    insert into FoodType
    (
        FoodType
        ,LanguageID
        ,FoodTypeSName
    )
    values
    (
        @FoodType
        ,@LanguageID
        ,@FoodTypeSName
    )

    if (@@error <> 0)
	    goto error

    set @FoodTypeId = scope_identity()
    
    if (@IsMacro = 1)
    begin
        insert into FoodTypeSearchMap
        (
            SearchFoodTypeId
            ,FoodTypeId
        )
        values
        (
            @FoodTypeId
            ,@FoodTypeId
        )
    end

    select @FoodTypeId
    
    commit transaction trans
    return(0)

    error:
        rollback transaction trans
        return (1)

go

grant execute on [Cuisine_FoodType_Add] to ExecuteOnlyRole

go

