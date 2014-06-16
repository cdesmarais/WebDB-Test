if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobRankRestaurantsForAvailabilityTonight]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobRankRestaurantsForAvailabilityTonight]
go

create procedure dbo.JobRankRestaurantsForAvailabilityTonight 
as 
begin

	set transaction isolation level read uncommitted
	set nocount on

	declare @MinRatingX10 int
	declare @MinRating float
	declare @DefaultMinRatingX10 int
	declare @NumRestInRotation int
	declare @POP_MinRatingX10 int
	declare @POP_MinRating float
	declare @POP_DefaultMinRatingX10 int
	declare @POP_MinSlotsPerRID int
		
	declare @debug bit
	set @debug = 0
	
	---------------------------------------------
	-- Get config options from valuelookup table
	---------------------------------------------	
	select @MinRatingX10 = ValueInt 
	from ValueLookup 
	where LKey = 'AT_MinRestRankingX10'
	and LType = 'WEBSERVER'

	set @MinRatingX10 = isnull( @MinRatingX10, 40 ) -- default if not found
	set @MinRating = cast( @MinRatingX10 as float ) / 10
	if @debug = 1 print '@MinRating: ' + cast( @MinRating as nvarchar ) 

	select @NumRestInRotation = ValueInt 
	from ValueLookup 
	where LKey = 'AT_NumRestInRotation'
	and LType = 'WEBSERVER'

	set @NumRestInRotation = isnull( @NumRestInRotation, 50 )  -- default if not found
	if @debug = 1 print '@NumRestInRotation: ' + cast( @NumRestInRotation as nvarchar ) 

	---------------------------------------------
	-- Get the same values for AT POP
	---------------------------------------------
	select @POP_MinRatingX10 = ValueInt 
	from ValueLookup 
	where LKey = 'ATPOP_MinRestRankingX10'
	and LType = 'WEBSERVER'

	set @POP_MinRatingX10 = isnull( @POP_MinRatingX10, 40 ) -- default if not found
	set @POP_MinRating = cast( @POP_MinRatingX10 as float ) / 10
	if @debug = 1 print '@POP_MinRating: ' + cast( @POP_MinRating as nvarchar ) 
	
	select @POP_MinSlotsPerRID = ValueInt 
	from ValueLookup 
	where LKey = 'ATPOP_MinSlotsPerRID'
	and LType = 'WEBSERVER'

	set @POP_MinSlotsPerRID = isnull( @POP_MinSlotsPerRID, 25 )  -- default if not found

	--Ratings data display
	declare @ReviewInceptionDays int
	declare @ReviewInceptionCutoffDate datetime

	--Ratings data display logic
	select	@ReviewInceptionDays = ValueInt 
	from	ValueLookup 
	where	LKey = 'RestReviewInceptionDays' 
	and		LType = 'WEBSERVER'

	set		@ReviewInceptionDays = isnull(@ReviewInceptionDays, 30)
	set		@ReviewInceptionCutoffDate = dateadd(dd, @ReviewInceptionDays*-1, getdate())

	-- Set start and end times for checking POP slots (4:30-9:30)
	declare  @dtStartRange datetime
			,@dtEndRange datetime
			
	set		@dtStartRange = '1900-01-01 16:30:00.000'
	set		@dtEndRange = '1900-01-01 22:30:00.000'

	-- The following query is used 4 times.  Select results into a temp table for 
	-- readability, maintainability, performance.
	select		row_number()  over(order by TotalSeatedStandardCovers desc) rownum
				,r.rid
				,n.metroareaid
				,n.macroid
				,-1 as DipCount
	into		#TempRestInfoWithRowNumbers 
	from		RestaurantCoverCounts rcc
	inner join	Restaurant r
	on			r.rid = rcc.rid
	inner join	Neighborhood n
	on			r.neighborhoodid = n.neighborhoodid
	inner join	DFFDailySummaryRIDStatsHolding dff
	on			dff.webrid = rcc.rid
	inner join	RestaurantImage ri
	on			ri.rid = r.rid
	left join	RestaurantJustAdded rja
	on			r.rid = rja.rid
	where		r.RestStateID in (1,5,6,7,13,16)
	and			dff.AverageOverallRating >= @MinRating
	and			ri.ShowImage = 1 
	and			ri.Thumbnail is not null
	and			isnull(dff.BlackListFlag,0) != 1
	and			isnull(rja.DateAdded,'2000-01-01') < @ReviewInceptionCutoffDate
	and			r.MinOnlineOptionID <= 2 
	and			r.MaxOnlineOptionID >=2
	and 		r.LimitedBooking = 0 --exclude RBR restaurants
	if (@@error != 0)
		goto on_error

	-- Find total pop slots.  Need to consider 4 different cases in the 
	-- IncentiveVW table:
	--		1---Start and End times between the time ranges 5PM to 9 PM.
	--		2---StartTime is between the time range and End time is outside of time range 9PM to 10:30PM
	--		3---EndTime falls in Time Range Ex: 4PM to 6PM then we want to cover 5PM to 6PM
	--		4---Start and End Times include the set time range (Ex: 4PM to 11PM)

	select	row_number()  over(order by DipCount desc) rownum
			,a.RID
			,a.MetroAreaID
			,a.MacroID
			,a.DipCount
	into #POP_TempRestInfoWithRowNumbers
	from (
		select  r.RID 
			   ,n.MetroAreaID 
			   ,n.MacroID
			   ,sum(
					case when (I.StartTime >=@dtStartRange AND dbo.fGetTimePart(dateadd(mi,-15, I.EndTime)) <= @dtEndRange)  --SCENARIO - 1
							  then DateDiff(mi, i.StartTime, I.EndTime)/15
						 when (I.StartTime >= @dtStartRange AND I.StartTime <= @dtEndRange AND dbo.fGetTimePart(dateadd(mi,-15, I.EndTime)) > @dtEndRange)--SCENARIO - 2
							  then DateDiff(mi, i.StartTime, DateAdd(mi, 15, @dtEndRange))/15
						 when (dbo.fGetTimePart(dateadd(mi,-15, I.EndTime)) >= @dtStartRange AND dbo.fGetTimePart(dateadd(mi,-15, I.EndTime)) <= @dtEndRange) --SCENARIO - 3
							  then DateDiff(mi, @dtStartRange, I.EndTime)/15
						 when (I.StartTime < @dtStartRange AND dbo.fGetTimePart(dateadd(mi,-15, I.EndTime)) > @dtEndRange) --SCENARIO - 4
							  then DateDiff(mi, @dtStartRange, DateAdd(mi, 15, @dtEndRange))/15				 
						 else 0
					end
				) as Dipcount 
		from		IncentiveVW i
		inner join	IncentiveRestaurantStatus irs
		on			i.RID =irs.RID
		inner join	Restaurant r
		on			i.RID = r.RID
		inner join	Neighborhood n 
		on			r.NeighborhoodID = n.NeighborhoodID
		inner join	MetroArea m
		on			m.MetroAreaID = n.MetroAreaID
		inner join	DFFDailySummaryRIDStatsHolding dff
		on			dff.webrid = r.rid
		left join	RestaurantJustAdded rja
		on			r.rid = rja.rid
		where		i.Active = 1
		and			i.LastMinutePopThresholdTime IS NULL
		and			irs.Active = 1
		and			m.Active = 1
		and			r.RestStateID in (1,5,6,7,13,16)
		and			dff.AverageOverallRating >= @POP_MinRating
		and			isnull(dff.BlackListFlag,0) != 1
		and			isnull(rja.DateAdded,'2000-01-01') < @ReviewInceptionCutoffDate
		and			r.MinOnlineOptionID <= 2 
		and			r.MaxOnlineOptionID >=2
		and 		r.LimitedBooking = 0 --exclude RBR restaurants
		group by	 r.RID
					,n.MetroAreaID 
					,n.MacroID
	) a
	where a.DipCount >= @POP_MinSlotsPerRID
		
	if (@@error != 0)
		goto on_error	
	
	--------------------------------------------------------------------------------
	-- Combine two datasets and order them in order of ATPOP rests followed by regular AT restaurants.
	--------------------------------------------------------------------------------
	--Dump data from AT_POP into temp table.
	select		rownum
				,RID
				,MetroAreaID
				,MacroID
				,DipCount
	into		#AT_CombineRestInfoData
	from		#POP_TempRestInfoWithRowNumbers
	
	if (@@error != 0)
		goto on_error	
		
	--Update #POP_TempRestInfoWithRowNumbers with regular AT rows to backfill them.
	insert into	#AT_CombineRestInfoData(
				rownum
				,RID
				,MetroAreaID
				,MacroID
				,DipCount
				)
	select		at.rownum
				,at.RID
				,at.MetroAreaID
				,at.MacroID
				,at.DipCount
	from		#TempRestInfoWithRowNumbers at
	left join	#POP_TempRestInfoWithRowNumbers atpop
	on			at.RID = atpop.RID
	where		atpop.RID is null
	
	if (@@error != 0)
		goto on_error	
	
	--order the combined dataset to have ATPOP rests followed by regular AT restaurants.
	select		row_number() over(order by DipCount desc, rownum asc) rownum
				,r.RID 
				,r.MetroAreaID 
				,r.MacroID
				,Case When (r.DipCount > 0) then 1 else 0 end as IsPop
	into		#AT_OrderedATRestInfoCombination
	from		#AT_CombineRestInfoData r

	if (@@error != 0)
		goto on_error	
	
	--------------------------------------------------------------------------------
	-- This query finds the restaurants that are ranked in the top 50 in each metro 
	-- when ranked by TotalCovers.
	--------------------------------------------------------------------------------
	
	--Metro List
	select		a.rid
				,a.metroareaid
				,count(*) metrorank
				,a.IsPop
	into		#TempMetroRankings	
	from		#AT_OrderedATRestInfoCombination a
	left join	#AT_OrderedATRestInfoCombination b 
	on			a.metroareaid = b.metroareaid
	and			a.rownum >= b.rownum
	group by	a.rid, a.metroareaid, a.IsPop
	having		count(*) <= @NumRestInRotation
	order by	a.metroareaid, count(*)
	
	if (@@error != 0)
		goto on_error

	--MacroList
	select		a.rid
				,a.macroid
				,count(*) macrorank
				,a.IsPop
	into 		#TempMacroRankings	
	from		#AT_OrderedATRestInfoCombination a
	left join	#AT_OrderedATRestInfoCombination b 
	on			a.macroid = b.macroid
	and			a.rownum >= b.rownum
	group by	a.rid, a.macroid, a.IsPop
	having		count(*) <= @NumRestInRotation
	order by	a.macroid, count(*) 
	
	if (@@error != 0)
		goto on_error

	begin tran
	
	delete AvailableTonightRanking
	
	if (@@error != 0)
		goto on_error
	
	insert			AvailableTonightRanking (rid, AvailableTonightMetroRank, AvailableTonightMacroRank, pop )
	select			isnull(metro.rid, macro.rid) rid, 
					metro.metrorank, 
					macro.macrorank,
					case when (ISNULL(metro.IsPop, 0) = 1 OR ISNULL(macro.IsPop, 0) = 1) then  1 else 0 END as Pop
	from			#TempMetroRankings metro
	full outer join	#TempMacroRankings macro
	on				metro.rid = macro.rid

	if (@@error != 0)
		goto on_error
				
	commit
	goto on_complete
	
on_error:	

	rollback
	raiserror('Could not update AvailableTonightRanking table', 16, 1)
	
on_complete:

	if object_id ('tempdb..#TempRestInfoWithRowNumbers') > 0   
		drop table #TempRestInfoWithRowNumbers
	if object_id ('tempdb..#TempMetroRankings') > 0   
		drop table #TempMetroRankings
	if object_id ('tempdb..#TempMacroRankings') > 0   
		drop table #TempMacroRankings
	if object_id ('tempdb..#POP_TempRestInfoWithRowNumbers') > 0   
		drop table #POP_TempRestInfoWithRowNumbers
	if object_id ('tempdb..#AT_CombineRestInfoData') > 0   
		drop table #AT_CombineRestInfoData	
	if object_id ('tempdb..#AT_OrderedATRestInfoCombination') > 0
		drop table #AT_OrderedATRestInfoCombination 		
		

end
go

GRANT EXECUTE ON [JobRankRestaurantsForAvailabilityTonight] TO ExecuteOnlyRole
go

