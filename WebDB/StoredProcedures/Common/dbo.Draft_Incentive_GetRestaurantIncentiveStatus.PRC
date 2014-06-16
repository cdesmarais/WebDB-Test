
if exists (select * from   dbo.sysobjects where  id = object_id(N'[dbo].[Draft_Incentive_GetRestaurantIncentiveStatus]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_GetRestaurantIncentiveStatus] 
go

create procedure [dbo].[Draft_Incentive_GetRestaurantIncentiveStatus]
(
    @RID int
)
as
	declare @OTCovers as int
	declare @POPCovers as int

	select 
		top 1 @OTCovers = OTCovers,@POPCovers = POPCovers
	from	
		IncentiveHistory
	where 
		RID =  @RID  
	order by 
		IncHistID desc
	
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
        ,@OTCovers as OTCovers
        ,@POPCovers as POPCovers
    from
        DraftIncentiveRestaurantStatus I

        inner join IncentiveStatus Ic on
        I.IncStatusID = Ic.IncStatusID

        inner join RestaurantVW R on
        I.RID = R.RID

        inner join RestaurantState rs on
        R.RestStateID = rs.RestStateID
        
    where
        I.RID = @RID
go

grant execute on [Draft_Incentive_GetRestaurantIncentiveStatus] to ExecuteOnlyRole

go