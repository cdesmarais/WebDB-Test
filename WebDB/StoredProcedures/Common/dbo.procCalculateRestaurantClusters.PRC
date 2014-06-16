if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procCalculateRestaurantCorrelation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procCalculateRestaurantCorrelation]
GO

CREATE PROCEDURE dbo.procCalculateRestaurantCorrelation
	As

SET NOCOUNT ON

set transaction isolation level read uncommitted

/*
Summarization of steps in this proc
1.	Initialize configurations from ValueLookup
2.	Initialize the "seed" or restaurant to cluster and
	the count of remaining restaurants left to cluster.
3.	Begin the while loop, that breaks once the minimum
	configured cluster size is met, or the minimum
	correlation is met, or the restaurants left to cluster
	are exhausted.
	a.	Calculate a cluster based on the seed RID.
	b.	Test the temp cluster thresholds.
	c.	If thresholds are met, then store the cluster
		in the RestaurantDFFCategoryCorrelation table.
	d.	Reset loop values.
		1)	Once we've hit approc 20% (as config'ed for now)
			of available restaurants tested for a cluster, 
			it's time to reduce thresholds.
		2)	TempCluster table is dropped.
		3)	Find a new seed.
*/

--Configuration parameters
declare @correlation_threshold float
declare @dff_total_threshold int
declare @seeds_to_test float --percentage of the available restaurants to cluster as a decimal
declare @correlation_backoff_interval float
declare @min_cluster_backoff_interval int
declare @min_cluster_size int
declare @min_correlation float
declare @cur_cluster_size int

--Local values
declare @seed_rid int
declare @temp_cluster_id int
declare @temp_cluster_count int
declare @it_counter int
declare @avail_restaurants int


--Assign configuration values
--Note that altering these values may significantly affect how clusters
--are created.  Any modifications should be tested first to ensure
--understanding of the outcome.
select					@correlation_threshold =	cast(ValueChar as float)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugCorrelation'

select					@dff_total_threshold =		cast(ValueChar as int)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugDFFMin'

select					@seeds_to_test =			cast(ValueChar as float)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugPctSeedsToTest'

select					@cur_cluster_size =			cast(ValueChar as int)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugInitCurClusterSize'

select					@correlation_backoff_interval = cast(ValueChar as float)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugCorrelBackoffInterval'

select					@min_cluster_backoff_interval = cast(ValueChar as int)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugClusterSizeBackoff'

select					@min_cluster_size =			cast(ValueChar as int)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugMinClusterSize'

select					@min_correlation =			cast(ValueChar as float)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugMinCorrelation'

--Init local vars
set @seed_rid = 0
set @temp_cluster_count = 0
set @it_counter = 0

--Iterate through restaurants as "seeds" until we've clustered all of them
--Initialize seed, join to restaurant to make sure the seed is valid
select			top 1 @seed_rid = dr.WebRID
from			DFFDailySummaryRIDStatsHolding dr
inner join		Restaurant r
on				dr.WebRID = r.RID
left join		RestaurantDFFCategoryCorrelation rdc
on				dr.WebRID = rdc.RID
where			rdc.RID is null
order by		newid() --random seed

--Initialize how many restaurants in our pool
select			@avail_restaurants = count('x')
from			DFFDailySummaryRIDStatsHolding dr
inner join		Restaurant r
on				dr.WebRID = r.RID
left join		RestaurantDFFCategoryCorrelation rdc
on				dr.WebRID = rdc.RID
where			rdc.RID is null

-- If we run out of rids to cluster, or our backoff has made the cluster counts too small or the correlations aren't relevant then break out of the loop
while @seed_rid != 0 and @min_cluster_size <= @cur_cluster_size and @min_correlation <= @correlation_threshold
begin

	set @it_counter = @it_counter + 1

	--Make sure #TempCluster isn't currently in the way
	if object_id('tempdb..#TempCluster') is not null 
		drop table #TempCluster

	--Populate the #TempCluster table with a candidate cluster based on the current seed.
	--If the temp cluster meets thresholds, it will be stored
	select 							cor.Rid, 						
									cor.Correlation
	into							#TempCluster
	from							(
									select * from dbo.fDFFCategoryCorrelationTable(@seed_rid,@dff_total_threshold)									
									) cor
	where correlation > @correlation_threshold
	order by correlation desc

	--Test temp cluster thresholds
	select @temp_cluster_count = count('x') from #TempCluster

	if  @temp_cluster_count > @cur_cluster_size
	begin
		--print 'Valid cluster count, about to create a cluster with seed rid ' + cast(@seed_rid as varchar)
		
		insert into RestaurantDFFCategoryCluster 
		(MinCorrelation,SeedRID,CreateDateUTC)
		values (@correlation_threshold,@seed_rid,getutcdate())
		
		--Get the cluster id
		set @temp_cluster_id = scope_identity()
		
		--First insert the seed with a correlation of 1
		insert into RestaurantDFFCategoryCorrelation
		(ClusterID,RID,CorrelationToSeed,IsOutlier,CreateDateUTC)
		values (@temp_cluster_id,@seed_rid,1,0,getutcdate())
		
		--Populate the correlation table
		insert into RestaurantDFFCategoryCorrelation
		(ClusterID,RID,CorrelationToSeed, IsOutlier, CreateDateUTC)
		select @temp_cluster_id, RID, Correlation, 0, getutcdate()
		from #TempCluster
		
	end -- end if @temp_cluster_count > @cur_cluster_size

	-- check to see if we've hit the backoff threshold
	if @it_counter > @avail_restaurants * @seeds_to_test
	begin
		--Reset the iterator
		set @it_counter = 0
		set @correlation_threshold = @correlation_threshold - @correlation_backoff_interval
		set @cur_cluster_size = @cur_cluster_size - @min_cluster_backoff_interval
		select			@avail_restaurants = count('x')
		from			DFFDailySummaryRIDStatsHolding r
		left join		RestaurantDFFCategoryCorrelation rdc
		on				r.WebRID = rdc.RID
		where			rdc.RID is null
		--print 'Reset clustering @correlation_threshold: ' + cast(@correlation_threshold as varchar) + ' @cur_cluster_size: ' + cast(@cur_cluster_size as varchar)
	end -- end @it_counter > @avail_restaurants * @seeds_to_test
		
	--Reset the seed
	set @seed_rid = 0

	select			top 1 @seed_rid = dr.WebRID
	from			DFFDailySummaryRIDStatsHolding dr
	inner join		Restaurant r
	on				dr.WebRID = r.RID
	left join		RestaurantDFFCategoryCorrelation rdc
	on				dr.WebRID = rdc.RID
	where			rdc.RID is null
	order by		newid() --random seed

	--debug statements, remove after testing
	--if @it_counter%5 = 0
		--print '@it_counter ' + cast(@it_counter as varchar)
	
end -- End of while loop

--Clean up #TempCluster before exit
if object_id('tempdb..#TempCluster') is not null 
	drop table #TempCluster

GO

GRANT EXECUTE ON [procCalculateRestaurantCorrelation] TO ExecuteOnlyRole

GO
