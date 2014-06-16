


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_InsertSuppressDayHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_InsertSuppressDayHistory]
go


create procedure [dbo].[Incentive_InsertSuppressDayHistory]
(
    @RID int
    ,@LastHistID int 
    ,@ModifiedBy nvarchar(255) = null
)
as
    /* 
        This stored proc is a wrapper to Incentive_InsertIncentiveHistory proc. It first gets the 
        data of last history info and then execute the proc to insert new history.
    */
    -- declare variables
    declare @SignedBy nvarchar(255)
    declare @OldStartEndDates nvarchar(255)
    declare @NewStartEndDates nvarchar(255)
    declare @ContractSoldBy nvarchar(255)
    declare @DraftSubmitDate datetime
    declare @ContractEffectiveDate datetime 
    declare @IncHistID int

    --Get last history information
    Select
        @SignedBy = SignedBy
        ,@OldStartEndDates = OldStartEndDates
        ,@NewStartEndDates = NewStartEndDates
        ,@ContractSoldBy = ContractSoldBy
        ,@DraftSubmitDate = DraftSubmitDate
        ,@ContractEffectiveDate = ContractEffectiveDate
    from 
        IncentiveHistory
    where 
        RID = @RID
        and IncHistID = @LastHistID
   
 -- execute Incentive_InsertIncentiveHistory stored proc to insert history info.
    exec Incentive_InsertIncentiveHistory 
            @RID
            ,null
            ,@signedBy
            ,null
            ,null
            ,@NewStartEndDates
            ,@OldStartEndDates
            ,@ModifiedBy
            ,@ContractSoldBy
            ,@IncHistID output
            ,@DraftSubmitDate
            ,@ContractEffectiveDate
    
    Select @IncHistID
go

GRANT EXECUTE ON [Incentive_InsertSuppressDayHistory] TO ExecuteOnlyRole

go

