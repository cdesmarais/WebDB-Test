
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SearchSummaryByDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SearchSummaryByDay]
GO




CREATE PROCEDURE dbo.DBD_SearchSummaryByDay
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select SearchStatType, sum(coalesce(SearchStat,0)) as SearchStat, datediff(dd,DateAdded,getdate()) as SearchDay
from SearchStatsSummary
inner join SearchStatTypes on SearchStatsSummary.SearchStatTypeID = 
SearchStatTypes.SearchStatTypeID
where rank = -1 and datediff(dd,DateAdded,getdate()) < 32 and SearchStatsSummary.SearchStatTypeID in (11,12,13)
group by SearchStatType, Rank, datediff(dd,DateAdded,getdate())
order by datediff(dd,DateAdded,getdate())



GO
GRANT EXECUTE ON [DBD_SearchSummaryByDay] TO ExecuteOnlyRole

GO
