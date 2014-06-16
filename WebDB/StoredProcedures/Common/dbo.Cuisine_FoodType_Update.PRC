

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Cuisine_FoodType_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Cuisine_FoodType_Update]
go

create procedure [dbo].[Cuisine_FoodType_Update]
(
    @FoodTypeId int
    ,@FoodType nvarchar(200)
    ,@FoodTypeSName nvarchar(200)
    ,@IsCuisineTypeChanged bit
)
as
    --This stored procedure updates the cuisine information.
    declare @Count int 
    --begin transaction
    begin transaction
    
    --Update FoodType info.
    update 
        FoodType
    set
        FoodType = @FoodType
        ,FoodTypeSName = @FoodTypeSName
    where
        FoodTypeId = @FoodTypeId
    
    --if error 
    if @@error<>0
        goto Error
    
    /*
        Here IsCuisineTypechanged indicates that cuisine type has changed.
        i.e. we need to change the existing Macro/Micro value to other value.
        Here first check if FoodType is a macro and micro.
        1. If current type is macro then we need to delete entry from FoodTypeSearchMap
        2. If current type is micro then we need to add an entry to FoodTypeSearchMap.
    */
    if @IsCuisineTypeChanged = 1
    begin
        --Get count of FoodType. Ideally it would be 1 for macro and 0 for micro
        select
            @Count=count(FoodTypeId)
        from 
            FoodTypeSearchMap
        where
            FoodTypeId=@FoodTypeId
            and SearchFoodTypeId = @FoodTypeId
        
        if @Count <> 0
        begin
            --If change from macro to micro then delete entry of the foodtype.
            delete from
                FoodTypeSearchMap
            where
                FoodTypeId=@FoodTypeId
                and SearchFoodTypeId=@FoodTypeId
        end
        else
        begin
            --If change from micro to macro then insert entry of the foodtype.
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
        if @@error<>0
            goto Error
    end 
    
    commit transaction
    return(0)
        

    Error:
        rollback transaction
        return(1)
go

grant execute on [Cuisine_FoodType_Update] to ExecuteOnlyRole

go

