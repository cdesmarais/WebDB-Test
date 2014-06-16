if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_DataLoadLastMinutePOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_DataLoadLastMinutePOP]
GO

CREATE  PROCEDURE dbo.Incentive_DataLoadLastMinutePOP  
(  
     @RID int
    ,@LastMinutePOPThresholdTime time
    ,@POPStartTime DateTime
    ,@POPEndTime DateTime    
)  
AS  
 

DECLARE @dtYesterday datetime
set @dtYesterday = getdate() - 1

DECLARE @IncHistID int

exec dbo.Incentive_InsertIncentiveHistory
	@RID
	,'POP Imported'			-- @DipHistStatus
	,'Data Load'			-- @ContractSignedBy
	,null                   -- @NewDIPSlots
	,null                   -- @OriginalDIPSlots
	,null                   -- @NewDIPStartEndTimes
	,null                   -- @OldDIPStartEndTimes
	,'Data Load'			-- @ChangedBy
	,null                   -- @ContractSoldBy
	,@IncHistID OUTPUT
	,@dtYesterday			-- @DraftSubmitDate
	,@dtYesterday			-- @ContractEffectiveDate	


DECLARE @EndDate DATETIME
SET @EndDate = dateadd(year,10,@dtYesterday)
  

EXEC Incentive_UpdateRestaurantIncentiveStatus1
   @RID
  ,@IncHistID
  ,1              -- @DIPStatus (POP Customer)
  ,'OpenTable'    -- @ContractSignedBy
  ,@dtYesterday   -- @StartDate
  ,@EndDate       -- @EndDate
  ,null           -- @ContractSoldBy
  ,@dtYesterday   -- @ContractEffectiveDate

 
EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Sunday'					-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime


EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Monday'					-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime
	
EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Tuesday'					-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime
	
EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Wednesday'				-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime

EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Thursday'					-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime
	
EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Friday'					-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime
	
EXEC Incentive_InsertIncentive2 
	@RID
	,@dtYesterday				-- @dtYesterday
	,@EndDate					-- @EndDate
	,'Saturday'					-- @IncentiveDay
	,@POPStartTime	-- @StartTime
	,@POPEndTime	-- @EndTime
	,@IncHistID
	,@LastMinutePOPThresholdTime	
	
GO


GRANT EXECUTE ON [Incentive_DataLoadLastMinutePOP] TO ExecuteOnlyRole
GO
