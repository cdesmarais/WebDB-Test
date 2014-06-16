if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procClusterOutlierRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procClusterOutlierRestaurants]
GO

CREATE PROCEDURE dbo.procClusterOutlierRestaurants
As

SET NOCOUNT ON

set transaction isolation level read uncommitted

/*
Summarization of steps in this proc
1.	Initialize configurations from ValueLookup
2.	Create a cursor consisting of unclustered restaurants
3.	Compare the unclustered restaurant (outlier) with
	currently clustered restaurants and choose the cluster
	that has the highest summation of correlation with the outlier.
4.	Calculate the correlation to seed for the outlier to set the RID's
	position within the cluster.
*/


--Configuration parameters
declare @dff_total_threshold int
declare @min_cluster_match_threshold int

--Local values
declare @outlier_rid int
declare @seed_rid int
declare @correlation_to_seed_rid float
declare @top_cluster int
declare @top_cluster_count int
declare @top_cluster_sum float
declare @max_correlation float


--Assign configuration values
--Note that altering these values may significantly affect how clusters
--are created.  Any modifications should be tested first to ensure
--understanding of the outcome.
select					@dff_total_threshold =		cast(ValueChar as int)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugDFFMin'

select					@min_cluster_match_threshold = cast(ValueChar as int)
from					ValueLookup
where					LType =						'DATABASE'
and						LKey =						'SugMinClusterMatch'

--Iterate over the remaining unclustered RIDs and determine which cluster most
--correlates to the RID by a count from within an existing cluster of
--restaurants that exceed the minimum threshold.  Join to the restaurant
--table just to make sure that the WebRID exists.  There's not a FK constraint
--on DFFDailySummaryRIDStatsHolding for WebRID.
declare			curOutliers cursor for
select			r.WebRID
from			DFFDailySummaryRIDStatsHolding r
inner join		Restaurant rr
on				r.WebRID = rr.RID
left join		RestaurantDFFCategoryCorrelation rdc
on				r.WebRID = rdc.RID
where			rdc.RID is null
and				r.TotalDFFs > @dff_total_threshold

open curOutliers
fetch next from curOutliers into @outlier_rid

while @@fetch_status = 0
begin
	--reset local vars
	set @top_cluster = 0
	set @top_cluster_sum = 0
	set @top_cluster_count = 0
	set @max_correlation = 0.0
	set @seed_rid = 0

	--Here we will only correlate outliers to restaurants that are currently clustered
	--Note that once an outlier is clustered, it will be considered for match.  Also
	--note the order by, the sum(correlation) dictates the best cluster to assign the outlier to.
	select								top 1
										@top_cluster_sum =			sum(correlation),
										@top_cluster_count =		count('x'), 
										@top_cluster =				cor.ClusterID,
										@max_correlation =			max(correlation),
										@seed_rid =					cor.SeedRID
	from								(
										select						* 
										from						fDFFCategoryOutlierCorrelationTable(@outlier_rid,@dff_total_threshold)	
										) cor
	group by							cor.ClusterID, cor.SeedRID
	having								count('x') > @min_cluster_match_threshold
	order by							sum(correlation) desc

	--For debug 
	--print 'The cluster for ' + cast(@outlier_rid as varchar) + ' is ' + cast(@top_cluster as varchar)+ ' with a cluster sum of ' + cast(@top_cluster_sum as varchar) + ' and a cluster count of ' + cast(@top_cluster_count as varchar) + ' and a max correlation of ' + cast(@max_correlation as varchar)

	if @top_cluster > 0
	begin
		declare @tmp_correlation_to_seed float
		set @tmp_correlation_to_seed = 0
		
		--Determine the correlation to seed for the outlier
		select							@tmp_correlation_to_seed = dbo.fDFFCategoryCorrelation(ds1.WebRID,ds2.WebRID)
		from							dffdailysummaryridstatsholding ds1
		cross join						DFFDailySummaryRIDStatsHolding ds2
		where							ds1.WebRID = @outlier_rid
		and								ds2.WebRID = @seed_rid
			
		insert into						RestaurantDFFCategoryCorrelation
										(ClusterID, RID, CorrelationToSeed, IsOutlier, CreateDateUTC)
		values							(@top_cluster, @outlier_rid, @tmp_correlation_to_seed, 1, getutcdate())
	end -- End of if @top_cluster > 0

	fetch next from curOutliers into @outlier_rid

end -- End of curOutliers

close curOutliers
deallocate curOutliers

GO

GRANT EXECUTE ON [procClusterOutlierRestaurants] TO ExecuteOnlyRole

GO
