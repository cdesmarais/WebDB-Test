--This proc gets Restaurant POP staus data.It gets the currently active restaurant status data.

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetRestaurantIncentiveStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetRestaurantIncentiveStatus]
go

create procedure [dbo].[Incentive_GetRestaurantIncentiveStatus]
(
    @RID int
)
as
    select
        i.RID
        ,R.RName
        ,Ic.Status
        ,I.ContractSignedBy
        ,I.StartDate
        ,I.EndDate
        ,rs.RState as RestStatus
        ,I.ContractSoldBy
        ,I.SecondarySalesRep
        ,I.ContractEffectiveDate
        ,ih.OTCovers
        ,ih.POPCovers
    from
        IncentiveRestaurantStatus I

        inner join IncentiveStatus Ic on
        I.IncStatusID = Ic.IncStatusID

        inner join RestaurantVW R on
        I.RID = R.RID

        inner join RestaurantState rs on
        R.RestStateID = rs.RestStateID
        
        inner join IncentiveHistory ih on
        I.ActiveIncHistID = ih.IncHistID
    where
        I.RID = @RID and
        i.Active = 1
go

grant execute on [Incentive_GetRestaurantIncentiveStatus] to ExecuteOnlyRole

go
