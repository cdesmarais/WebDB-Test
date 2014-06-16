


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_CancelPOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_CancelPOP]
go


create procedure [dbo].[Incentive_CancelPOP]
(
    @RID int
    ,@CreatedBy nvarchar(255)
)
as
    /*This procedure cancel the POP configuration (i.e. from "POP Customer" to "Not a POP Customer").
      1.First check if POP configuration exists for the restaurant.
      2.If POP exists then check if POP status is "NOT a POP customer". if yes then there is no need to 
        make changes to POP configuration.
      3.Insert data to history table. Here we take the unchanged values from previous active history id.
      4.Insert data to incentive restaurant status table. Here we will take unchanged data from previous incentive restaurant status id.
    */
    declare @ActiveIncHistID int
    declare @IncResStatusID int
    declare @IncStatusID int
    declare @NewIncHistID int
    declare @ContractSignedBy varchar(255)
    declare @StartDate datetime
    declare @EndDate datetime
    declare @ContractSoldBy varchar(255)
    declare @ContractEffectiveDate datetime
    declare @SubmitDate datetime  
    set @SubmitDate = getdate() -- current date  
    
    -- get current Active incentive history id and Incentive restaurant status Id.
    select
        @ActiveIncHistID =  ActiveIncHistID 
        ,@IncResStatusID = IncResStatusID
        ,@IncStatusID = IncStatusID
    from 
        IncentiveRestaurantStatus
    where 
        RID = @RID
    
    -- if Active history Id exists then only insert as there must be POP configured to cancel POP.
    if (@ActiveIncHistID is not null and @IncStatusID = 1) -- 1= POP customer
    begin
        --Insert into incentive history
        insert into IncentiveHistory
        (
            RID   
            ,CreateDate   
            ,IncHistStatusID   
            ,SignedBy  
            ,NewDIPSlots  
            ,OriginalDIPSlots  
            ,NewStartEndDates  
            ,OldStartEndDates  
            ,ChangedBy  
            ,ContractSoldBy  
            ,DraftSubmitDate  
            ,ContractEffectiveDate  
        ) 
        (
            --Select data which was last live data i.e active history id
            select
                @RID
                ,@SubmitDate
                ,5 -- 5= POP Cancelled
                ,SignedBy
                ,NewDIPSlots
                ,OriginalDIPSlots
                ,NewStartEndDates
                ,OldStartEndDates
                ,@CreatedBy
                ,ContractSoldBy
                ,@SubmitDate
                ,ContractEffectiveDate
            from 
                IncentiveHistory
            where
                IncHistId = @ActiveIncHistID
        ) 
        select @NewIncHistID = scope_identity()  
        
        select
            @ContractSignedBy = ContractSignedBy
            ,@StartDate = StartDate
            ,@EndDate = EndDate
            ,@ContractSoldBy = ContractSoldBy
            ,@ContractEffectiveDate = ContractEffectiveDate
        from
            IncentiveRestaurantStatus
        where 
            IncResStatusID = @IncResStatusID  
        -- update restaurant incentive status
        exec Incentive_UpdateRestaurantIncentiveStatus1 
            @RID
            ,@NewIncHistID
            ,2 --2=Not a POP customer
            ,@ContractSignedBy
            ,@StartDate
            ,@EndDate
            ,@ContractSoldBy
            ,@ContractEffectiveDate
            
    end
go

GRANT EXECUTE ON [Incentive_CancelPOP] TO ExecuteOnlyRole

go

