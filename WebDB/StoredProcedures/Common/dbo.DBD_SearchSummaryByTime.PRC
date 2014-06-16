
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SearchSummaryByTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SearchSummaryByTime]
GO



CREATE PROCEDURE dbo.DBD_SearchSummaryByTime
(
	@StartTime as datetime
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select SearchStatType, sum(coalesce(SearchStat,0)) as SearchStat, datediff(mi,DateAdded,@StartTime) as SearchMinute
from SearchStatsSummary
inner join SearchStatTypes on SearchStatsSummary.SearchStatTypeID = 
SearchStatTypes.SearchStatTypeID
where rank = -1 and datediff(mi,DateAdded,@StartTime) < 60 and datediff(mi,DateAdded,@StartTime) >= 0
group by SearchStatType, Rank, datediff(mi,DateAdded,@StartTime)
order by datediff(mi,DateAdded,@StartTime)

GO


GRANT EXECUTE ON [DBD_SearchSummaryByTime] TO ExecuteOnlyRole

GO
