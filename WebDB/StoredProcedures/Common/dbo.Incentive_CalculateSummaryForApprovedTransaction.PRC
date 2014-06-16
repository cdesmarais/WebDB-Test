

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_CalculateSummaryForApprovedTransaction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_CalculateSummaryForApprovedTransaction]
go


create procedure [dbo].[Incentive_CalculateSummaryForApprovedTransaction]
(
	@IncentativeHistoryID int
)
as

/*
	Calculate Summary fields such as 
	1) Total Slot for the POP approval transaction
	2) Total Luch Prim Slot for the POP approval transaction
	3) Total Diner Prim Slot for the POP approval transaction
	4) Prior SD POP Status
	5) Current SD POP Status
	6) Prior Total Luch Prim Slot before current POP approval transaction
	7) Prior Total Diner Prim Slot before current POP approval transaction		
*/
	declare @RID int
	
	declare @CurrentLunchPrimeSlots int
	declare @CurrentDinerPrimeSlots int
	declare @CurrentTotalSlots int
	declare @CurrentSDPOPStatus bit
	declare @SDPOPEnableDate datetime
	declare @SDPOPDisableDate datetime
	
	--Getting RID associated with Incidenet Histroy
	select
		@RID = ih.rid
	from
		IncentiveHistory ih
	where
		ih.IncHistID = @IncentativeHistoryID
		
	/*
		Getting Diner and Lunch Prime slots and Total Slots
	*/
	select 
		@CurrentLunchPrimeSlots = sum  
		(      
		  dbo.fCalculatePrimeTimePOPSlotsCount(i.StartTime , i.EndTime, 'L')      
		)     
		,@CurrentDinerPrimeSlots = sum  
		(       
		  dbo.fCalculatePrimeTimePOPSlotsCount(i.StartTime , i.EndTime,'D')      
		) 
		,@CurrentTotalSlots = sum(datediff(mi,i.StartTime, i.EndTime)/15) 
	from
		IncentiveVW i
	where
			i.RID = @RID
		and	i.Active = 1
		and i.LastMinutePopThresholdTime IS NULL  -- Excluding sameday POP.  
		
		
	/*
		Getting current SD POP Status.
	*/
	set @CurrentSDPOPStatus = 0
	
	if exists (select 1 from IncentiveVW where RID =@RID and LastMinutePopThresholdTime is not null and Active = 1)
	begin
		set @CurrentSDPOPStatus = 1
	end
	
	--Defult set to InActive.
	set @CurrentSDPOPStatus = isnull(@CurrentSDPOPStatus,0)
	
	-- Setting default value to Same Day POP enable and disable date.
	set @SDPOPEnableDate = null
	set @SDPOPDisableDate =null
	
	--Getting Same Day POP Enable and Disable date if applicable.
	select	
		 @SDPOPEnableDate = max(i.CreateDate)
		,@SDPOPDisableDate = case  
			when @CurrentSDPOPStatus = 1  then  
				null  
			else  
				max(i.DateDisabled)
		end 
	from
		IncentiveVW i
	where
		RID = @RID
	and i.LastMinutePopThresholdTime is not null  
	
	/*
		Updating current Incentive History table with all summary fields
	*/
	update
		IncentiveHistory
	set
		 CurrentSDPOPStatus = @CurrentSDPOPStatus
		,SDPOPEnableDate= @SDPOPEnableDate
		,SDPOPDisableDate =@SDPOPDisableDate
		,CurrentDinnerPrimeTimeSlots=@CurrentDinerPrimeSlots
		,CurrentLunchPrimeTimeSlots=@CurrentLunchPrimeSlots
		,CurrentTotalSlots =@CurrentTotalSlots
	where
		IncHistID = @IncentativeHistoryID
go

grant execute on [Incentive_CalculateSummaryForApprovedTransaction] to ExecuteOnlyRole

go

