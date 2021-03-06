if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_InsertIncentiveHistory_v5]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_InsertIncentiveHistory_v5]
go


create procedure [dbo].[Incentive_InsertIncentiveHistory_v5]
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
    ,@bLastMinuteEnable bit = null
    ,@OriginalLastMinuteSlots varchar(300) = null
    ,@NewLastMinuteSlots varchar(300) = null 
	,@IsCommissionable bit = 0
	,@ContractSoldByID int = null
	,@SecondarySalesRep nvarchar(255) = null
	,@SecondarySalesRepID int = null
	,@OTCovers int
	,@POPCovers int
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
        ,LastMinuteEnable
        ,OriginalLastMinuteSlots  
        ,NewLastMinuteSlots      
		,IsCommissionable
		,ContractSoldByID
		,SecondarySalesRep
		,SecondarySalesRepID
		,OTCovers
		,POPCovers
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
        ,@bLastMinuteEnable
        ,@OriginalLastMinuteSlots
        ,@NewLastMinuteSlots
		,@IsCommissionable
		,@ContractSoldByID
		,@SecondarySalesRep
		,@SecondarySalesRepID
		,@OTCovers
		,@POPCovers
    )
    
    select @IncHistID = scope_identity()

go

GRANT EXECUTE ON [Incentive_InsertIncentiveHistory_v5] TO ExecuteOnlyRole

go


