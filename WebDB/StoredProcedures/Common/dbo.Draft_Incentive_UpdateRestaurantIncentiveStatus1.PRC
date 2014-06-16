

--This procedure insert the drafted POP status data.

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_UpdateRestaurantIncentiveStatus1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_UpdateRestaurantIncentiveStatus1]
go

create procedure [dbo].[Draft_Incentive_UpdateRestaurantIncentiveStatus1]
(
    @RID int 
    ,@DIPStatus int 
    ,@ContractSignedBy nvarchar(255)
    ,@StartDate datetime
    ,@EndDate datetime
    ,@ContractSoldBy nvarchar(255)
    ,@POPAction nvarchar(255)
	,@ContractSoldByID int
	,@SecondarySalesRep nvarchar(255)
	,@SecondarySalesRepID int
)

as

    declare @IncResStatusID int
    declare @dCurrentDate datetime
    declare @POPActionID int

    select 
        @POPActionID = IncHistStatusID 
    from 
        IncentiveHistoryStatus 
    where 
        Status = @POPAction     

    --select all the Incentive restaturant statusID for the restaurant.
    select 
        @IncResStatusID = IncResStatusID 
    from 
        DraftIncentiveRestaurantStatus
    where 
        RID = @RID

    --If id exists then delete that id.
    if(@IncResStatusID is not null)
	begin
	-- delete the old record.
        delete from 
            DraftIncentiveRestaurantStatus 
        where 
            IncResStatusID = @IncResStatusID and
            RID = @RID
    end
	
    --Insert new information '

    insert into DraftIncentiveRestaurantStatus
    (
        RID
        ,IncStatusID
        ,ContractSignedBy
        ,StartDate
        ,EndDate
        ,ContractSoldBy
        ,ContractEffectiveDate
        ,IncHistStatusID
		,ContractSoldByID
		,SecondarySalesRep
		,SecondarySalesRepID
    )
    values
    (
        @RID
        ,@DIPStatus
        ,@ContractSignedBy
        ,@StartDate
        ,@EndDate
        ,@ContractSoldBy
        ,Getdate()
        ,@POPActionID
		,@ContractSoldByID
		,@SecondarySalesRep
		,@SecondarySalesRepID
    )
go

grant execute on [Draft_Incentive_UpdateRestaurantIncentiveStatus1] to ExecuteOnlyRole

go

