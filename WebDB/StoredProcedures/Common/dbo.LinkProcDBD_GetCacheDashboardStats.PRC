
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LinkProcDBD_GetCacheDashboardStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LinkProcDBD_GetCacheDashboardStats]
GO



CREATE procedure [dbo].[LinkProcDBD_GetCacheDashboardStats]
(
	@source					varchar(64)	= null,
	@RestsCached					int		OUTPUT,
	@AvgResponseTimeSingle			dec(9,2)		OUTPUT,
	@AvgResponseTimeMulti			dec(9,2)		OUTPUT,
	@AvgRestsPerSearch				dec(9,2)		OUTPUT,
	@CacheHitPcntAll				dec(9,2)		OUTPUT,
	@CacheHitPcntCacheCapable			dec(9,2)		OUTPUT,
	@CacheHitPcntCached				dec(9,2)		OUTPUT,
	@PcntActiveCachedVsCacheCapable 		dec(9,2)		OUTPUT,
	@PcntActiveCachedVsTotal			dec(9,2)		OUTPUT
)
as

/*
This proc gets called by the proc named "DBD_CacheDashboardStats" in WebLogDB which in turn is called by
the SQL Job named "Update Dashboard Stats"
*/

set nocount on

declare	 	@msecs				as bigint
		,@curdate				as datetime
		,@MaxID				as int
		,@MinID				as int
		,@SearchCountTotal			as double precision
		,@SearchCountSingle			as double precision
		,@SearchCountMulti			as double precision
		,@CacheCountAllTotal			as double precision
		,@CacheCountCacheCapableTotal	as double precision
		,@CacheCountCachedTotal		as double precision
		

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
declare @cachelogids table (CacheLogID int )

INSERT INTO @cachelogids
select	 CacheLogID
from	dbo.CacheServerStats
where		CacheLogDate	>= dateadd(minute, -5, @curdate)
and		CacheLogDate	<= @curdate

select	 @MinID = min(CacheLogID)
		,@MaxID = max(CacheLogID)
from	@cachelogids


print '@MinID     = ' + coalesce(cast(@MinID as varchar(10)), 'null')
print '@MaxID     = ' + coalesce(cast(@MaxID as varchar(10)), 'null')
print '@curdate   = ' + coalesce(cast(@curdate as varchar(25)), 'null')
print '@curdate-5 = ' + coalesce(cast(dateadd(minute, 5, @curdate) as varchar(25)), 'null')

-- Skip to end if there is nothing to add
if (@MinID is null or @MaxID is null)
	RETURN

-- Get the duration of the stats for this period
select	@msecs = SUM(SamplePeriodMilliSec) 
from	dbo.CacheServerStats
where	(@source is null or Source = @source)
and		CacheLogID	>= @MinID
and		CacheLogID	<= @MaxID

-- Get denominators for the stats
select	 @SearchCountTotal				= coalesce(nullif(sum(cast(MsgCountAvailRequestSingle as bigint))
														+ sum(cast(MsgCountAvailRequestMulti as bigint)), 0), 1)
		,@SearchCountSingle				= coalesce(nullif(sum(cast(MsgCountAvailRequestSingle as bigint)), 0), 1)
		,@SearchCountMulti				= coalesce(nullif(sum(cast(MsgCountAvailRequestMulti as bigint)), 0), 1)
		,@CacheCountAllTotal			= coalesce(nullif(sum(cast(CacheCountAllTotal as bigint)), 0), 1)
		,@CacheCountCacheCapableTotal	= coalesce(nullif(sum(cast(CacheCountCacheCapableTotal as bigint)), 0), 1)
		,@CacheCountCachedTotal			= coalesce(nullif(sum(cast(CacheCountCachedTotal as bigint)), 0), 1)
from	dbo.CacheServerStats
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
from	dbo.CacheServerStats
where	CacheLogID	= @MaxID

-- Get the stats for the last 5 minutes
select	 @CacheHitPcntAll			= sum(cast(CacheCountAllHit as bigint)) / @CacheCountAllTotal
		,@CacheHitPcntCacheCapable	= sum(cast(CacheCountCacheCapableHit as bigint)) / @CacheCountCacheCapableTotal
		,@CacheHitPcntCached		= sum(cast(CacheCountCachedHit as bigint)) / @CacheCountCachedTotal
		,@AvgResponseTimeSingle =
			sum(cast(SearchResponseTimeSentSumSingle as bigint)) / @SearchCountSingle
		,@AvgResponseTimeMulti =
			sum(cast(SearchResponseTimeSentSumMulti as bigint)) / @SearchCountMulti
		,@AvgRestsPerSearch =
			(sum(cast(CacheCountAllTotal as bigint)) - sum(cast(MsgCountAvailRequestSingle as bigint)))
			/ @SearchCountMulti
from	dbo.CacheServerStats
where	(@source is null or Source = @source)
and		CacheLogID	>= @MinID
and		CacheLogID	<= @MaxID
GO


GRANT  EXECUTE  ON [dbo].[LinkProcDBD_GetCacheDashboardStats]  TO [ExecuteOnlyRole]
GO

