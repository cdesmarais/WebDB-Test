

--This proc deletes all drafted data for a given restaurant.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_DeletePOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_DeletePOP]
go

create procedure dbo.Draft_Incentive_DeletePOP

(
    @RID int
)

as

    --Delete drafted Incentive data
    delete from 
        DraftIncentive
    where 
        RID=@RID

    --delete POP restaurant status data.
    delete from 
        DraftIncentiveRestaurantStatus
    where 
        RID=@RID

go

grant execute on [Draft_Incentive_DeletePOP] to ExecuteOnlyRole

go

