

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_GetAllDraftSubmittedInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_GetAllDraftSubmittedInfo]
go


create Procedure [dbo].[Draft_Incentive_GetAllDraftSubmittedInfo]
as
    --This Proc gets all the drafted POP data.
    select  
        irs.RID
        ,r.RName+'-'+ cast(irs.RID as nvarchar(20)) as Restaurant --'Restaurant name - restaurantID'
        ,ihs.Status as POPAction
        ,irs.ContractSoldBy
        ,irs.ContractEffectiveDate
    from 
        DraftIncentiveRestaurantStatus irs

        inner join RestaurantVW r on --join restaurantVW
        r.RID = irs.RID

        left outer join IncentiveHistoryStatus ihs on
        irs.IncHistStatusID = ihs.IncHistStatusID
go

grant execute on [Draft_Incentive_GetAllDraftSubmittedInfo] to ExecuteOnlyRole

go


