

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_Delete]
go

create procedure [dbo].[Draft_Incentive_Delete]
(
    @RID int, 
    @IncentiveID int
)
as

    --Delete existing Incentive Record 

    delete from 
        DraftIncentive
    where 
        IncentiveID = @IncentiveID and
        RID = @RID
go

grant execute on [Draft_Incentive_Delete] to ExecuteOnlyRole

go

