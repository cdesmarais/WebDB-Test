

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_UpdateRestaurantIncentiveStatus1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_UpdateRestaurantIncentiveStatus1]
go


create procedure [dbo].[Incentive_UpdateRestaurantIncentiveStatus1]
(
    @RID int 
    ,@IncHistID int
    ,@DIPStatus int
    ,@ContractSignedBy nvarchar(255)
    ,@StartDate datetime
    ,@EndDate datetime
    ,@ContractSoldBy nvarchar(255)
    ,@ContractEffectiveDate datetime
)

as

    declare @IncResStatusID int
    declare @dCurrentDate datetime


/********************************************************************************
Update a record into Restaurant DIP Status table.  
The following DIPstatus are available and hard coded in this stored procedure
1 - DIP Customer
2 - Not a DIP Customer
3 - DO NOT DIP
*********************************************************************************/

    select 
        @IncResStatusID = IncResStatusID 
    from 
        IncentiveRestaurantStatus
    where 
        RID = @RID and
        Active = 1

--Insert new information '

    insert into IncentiveRestaurantStatus
    (
        RID
        ,IncStatusID
        ,ContractSignedBy
        ,StartDate
        ,EndDate
        ,ActiveIncHistID
        ,ContractSoldBy
        ,ContractEffectiveDate --Column to save POP Contract Effective Date
    )
    values
    (
        @RID
        ,@DIPStatus
        ,@ContractSignedBy
        ,@StartDate
        ,@EndDate
        ,@IncHistID
        ,@ContractSoldBy
        ,@ContractEffectiveDate
    )

    if(@IncResStatusID is not null)
	    begin
	-- Set the old record's active flag to false.
	        update 
                IncentiveRestaurantStatus 
            set 
                Active = 0
                ,DeActiveIncHistId = @IncHistID 
            where 
                IncResStatusID = @IncResStatusID and
                RID = @RID
        end

go

grant execute on [Incentive_UpdateRestaurantIncentiveStatus1] to ExecuteOnlyRole

go

