--$ create proc csCacheDashboardStats
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csCacheDashboardStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csCacheDashboardStats]
GO


CREATE procedure dbo.csCacheDashboardStats
(
	@source varchar(64) = null
)
as

set nocount on

declare	 @msecs							as bigint
		,@curdate						as datetime
		,@MaxID							as int
		,@MinID							as int
		,@SearchCountTotal				as double precision
		,@SearchCountSingle				as double precision
		,@SearchCountMulti				as double precision
		,@CacheCountAllTotal			as double precision
		,@CacheCountCacheCapableTotal	as double precision
		,@CacheCountCachedTotal			as double precision
		,@RestsCached					as int
		,@PcntActiveCachedVsTotal		as dec(9,2)
		,@PcntActiveCachedVsCacheCapable as dec(9,2)
		,@AvgResponseTimeSingle			as dec(9,2)
		,@AvgResponseTimeMulti			as dec(9,2)
		,@AvgRestsPerSearch				as dec(9,2)
		,@CacheHitPcntAll				as dec(9,2)
		,@CacheHitPcntCacheCapable		as dec(9,2)
		,@CacheHitPcntCached			as dec(9,2)

-- Initialize variables
set @curdate						= getdate()
set @RestsCached					= 0
set @PcntActiveCachedVsTotal		= 0
set @PcntActiveCachedVsCacheCapable	= 0
set @AvgResponseTimeSingle			= 0
set @AvgResponseTimeMulti			= 0
set @AvgRestsPerSearch				= 0
set @CacheHitPcntAll				= 0
set @CacheHitPcntCacheCapable		= 0
set @CacheHitPcntCached				= 0

-- Get the min/max LogID for the last 5 minutes for the source
select	 @MinID = min(CacheLogID)
		,@MaxID = max(CacheLogID)
from	CacheServerStats
where	(@source is null or Source = @source)
and		CacheLogDate	>= dateadd(minute, -5, @curdate)
and		CacheLogDate	<= @curdate

print '@MinID     = ' + coalesce(cast(@MinID as varchar(10)), 'null')
print '@MaxID     = ' + coalesce(cast(@MaxID as varchar(10)), 'null')
print '@curdate   = ' + coalesce(cast(@curdate as varchar(25)), 'null')
print '@curdate-5 = ' + coalesce(cast(dateadd(minute, 5, @curdate) as varchar(25)), 'null')

-- Skip to end if there is nothing to add
if (@MinID is null or @MaxID is null)
	goto INSERT_RECORDS

-- Get the duration of the stats for this period
select	@msecs = SUM(SamplePeriodMilliSec) 
from	CacheServerStats
where	(@source is null or Source = @source)
and		CacheLogID	>= @MinID
and		CacheLogID	<= @MaxID

-- Get denominators for the stats
select	 @SearchCountTotal				= coalesce(nullif(sum(cast(MsgCountAvailRequestSingle as bigint))
														+ sum(cast(MsgCountAvailRequestSingleMD as bigint))
														+ sum(cast(MsgCountAvailRequestMulti as bigint))
														+ sum(cast(MsgCountAvailRequestMultiMD as bigint)), 0), 1)
		,@SearchCountSingle				= coalesce(nullif(sum(cast(MsgCountAvailRequestSingle as bigint))
														+ sum(cast(MsgCountAvailRequestSingleMD as bigint)), 0), 1)
		,@SearchCountMulti				= coalesce(nullif(sum(cast(MsgCountAvailRequestMulti as bigint))
														+ sum(cast(MsgCountAvailRequestMultiMD as bigint)), 0), 1)
		,@CacheCountAllTotal			= coalesce(nullif(sum(cast(CacheCountAllTotal as bigint)), 0), 1)
		,@CacheCountCacheCapableTotal	= coalesce(nullif(sum(cast(CacheCountCacheCapableTotal as bigint)), 0), 1)
		,@CacheCountCachedTotal			= coalesce(nullif(sum(cast(CacheCountCachedTotal as bigint)), 0), 1)
from	CacheServerStats
where	(@source is null or Source = @source)
and		CacheLogID	>= @MinID
and		CacheLogID	<= @MaxID

-- Get the most recent data for:
-- 1) number of cached restaurants in Cache Server
-- 2) %age of active, cached restaurants in Cache Server (vs. total population)
-- 3) %age of active, cached restaurants in Cache Server (vs. Cache-Capable population)
select	 @RestsCached						= RestsStatusValid
		,@PcntActiveCachedVsTotal			= cast(RestsActiveCacheValid as bigint)
												/ coalesce(nullif(cast(RestsTotalActive as bigint), 0.0), 1.0)
		,@PcntActiveCachedVsCacheCapable	= cast(RestsActiveCacheValid as bigint)
												/ coalesce(nullif((cast(RestsActiveCacheValid as bigint)
																+ cast(RestsActiveCacheInvalid as bigint)), 0.0), 1.0)
from	CacheServerStats
where	CacheLogID	= @MaxID

-- Get the stats for the last 5 minutes
select	 @CacheHitPcntAll			= sum(cast(CacheCountAllHit as bigint)) / @CacheCountAllTotal
		,@CacheHitPcntCacheCapable	= sum(cast(CacheCountCacheCapableHit as bigint)) / @CacheCountCacheCapableTotal
		,@CacheHitPcntCached		= sum(cast(CacheCountCachedHit as bigint)) / @CacheCountCachedTotal
		,@AvgResponseTimeSingle =
			(sum(cast(SearchResponseTimeSentSumSingle as bigint)) + sum(cast(SearchResponseTimeSentSumSingleMD as bigint))) / @SearchCountSingle
		,@AvgResponseTimeMulti =
			(sum(cast(SearchResponseTimeSentSumMulti as bigint)) + sum(cast(SearchResponseTimeSentSumMultiMD as bigint))) / @SearchCountMulti
		,@AvgRestsPerSearch =
			(sum(cast(CacheCountAllTotal as bigint)) - sum(cast(MsgCountAvailRequestSingle as bigint)))
			/ @SearchCountMulti
from	CacheServerStats
where	(@source is null or Source = @source)
and		CacheLogID	>= @MinID
and		CacheLogID	<= @MaxID


INSERT_RECORDS:
select	 @RestsCached						'RestsCached'
		,@PcntActiveCachedVsTotal			'PcntActiveCachedVsTotal'
		,@PcntActiveCachedVsCacheCapable	'PcntActiveCachedVsCacheCapable'
		,@AvgResponseTimeSingle				'AvgResponseTimeSingle'
		,@AvgResponseTimeMulti				'AvgResponseTimeMulti'
		,@AvgRestsPerSearch					'AvgRestsPerSearch'
		,@CacheHitPcntAll					'CacheHitPcnt-All'
		,@CacheHitPcntCacheCapable			'CacheHitPcnt-CacheCapable'
		,@CacheHitPcntCached				'CacheHitPcnt-Cached'

print ''
print '@RestsCached                    = ' + coalesce(cast(@RestsCached as varchar(10)), 'null')
print '@PcntActiveCachedVsTotal        = ' + coalesce(cast(@PcntActiveCachedVsTotal as varchar(10)), 'null')
print '@PcntActiveCachedVsCacheCapable = ' + coalesce(cast(@PcntActiveCachedVsCacheCapable as varchar(10)), 'null')
print '@CacheHitPcntAll                = ' + coalesce(cast(@CacheHitPcntAll as varchar(10)), 'null')
print '@CacheHitPcntCacheCapable       = ' + coalesce(cast(@CacheHitPcntCacheCapable as varchar(10)), 'null')
print '@CacheHitPcntCachedAll          = ' + coalesce(cast(@CacheHitPcntCached as varchar(10)), 'null')
print '@AvgResponseTimeSingle          = ' + coalesce(cast(@AvgResponseTimeSingle as varchar(10)), 'null')
print '@AvgResponseTimeMulti           = ' + coalesce(cast(@AvgResponseTimeMulti as varchar(10)), 'null')
print '@AvgRestsPerSearch              = ' + coalesce(cast(@AvgRestsPerSearch as varchar(10)), 'null')
print ''

GO

GRANT EXECUTE ON [csCacheDashboardStats] TO ExecuteOnlyRole
GO

