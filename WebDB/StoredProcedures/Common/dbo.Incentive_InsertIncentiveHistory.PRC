


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_InsertIncentiveHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_InsertIncentiveHistory]
go


create procedure [dbo].[Incentive_InsertIncentiveHistory]
(
    @RID int
    ,@DipHistStatus nvarchar(255)
    ,@ContractSignedBy nvarchar(255)=null
    ,@NewDIPSlots ntext = null 
    ,@OriginalDIPSlots ntext = null 
    ,@NewDIPStartEndTimes nvarchar(255) = null 
    ,@OldDIPStartEndTimes nvarchar(255) = null 
    ,@ChangedBy nvarchar(255) = null
    ,@ContractSoldBy nvarchar(255) = null
    ,@IncHistID int output
    ,@DraftSubmitDate datetime
    ,@ContractEffectiveDate datetime
)
as
--This procedure inserts POP Configuration Changes to IncentiveHistory table. 
declare @IncHistStatusID int
declare @SubmitDate datetime
set @SubmitDate = getdate()

    -- if draft submitted date is null then set current date as draft submitted date.
    if @DraftSubmitDate is null
    begin
         set @DraftSubmitDate = @SubmitDate  
    end

    select 
        @IncHistStatusID = IncHistStatusID 
    from 
        IncentiveHistoryStatus 
    where 
        Status = @DipHistStatus 
    
    --Insert information
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
    values
    (
        @RID
        ,@SubmitDate 
        ,@IncHistStatusID 
        ,@ContractSignedBy
        ,@NewDIPSlots
        ,@OriginalDIPSlots
        ,@NewDIPStartEndTimes
        ,@OldDIPStartEndTimes 
        ,@ChangedBy
        ,@ContractSoldBy
        ,@DraftSubmitDate
        ,@ContractEffectiveDate
    )
    
    select @IncHistID = scope_identity()

go

GRANT EXECUTE ON [Incentive_InsertIncentiveHistory] TO ExecuteOnlyRole

go

