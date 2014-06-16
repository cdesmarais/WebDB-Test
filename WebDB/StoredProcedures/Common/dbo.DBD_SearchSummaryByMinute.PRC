if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SearchSummaryByMinute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SearchSummaryByMinute]
GO




CREATE PROCEDURE dbo.DBD_SearchSummaryByMinute
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select SearchStatType, sum(coalesce(SearchStat,0)) as SearchStat, datediff(mi,DateAdded,getdate()) as SearchMinute
from SearchStatsSummary
inner join SearchStatTypes on SearchStatsSummary.SearchStatTypeID = 
SearchStatTypes.SearchStatTypeID
where rank = -1 and datediff(mi,DateAdded,getdate()) < 60
group by SearchStatType, Rank, datediff(mi,DateAdded,getdate())
order by datediff(mi,DateAdded,getdate())

GO


GRANT EXECUTE ON [DBD_SearchSummaryByMinute] TO ExecuteOnlyRole

GO
