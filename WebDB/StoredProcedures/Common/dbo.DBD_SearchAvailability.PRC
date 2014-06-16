if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SearchAvailability]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SearchAvailability]
GO




CREATE PROCEDURE dbo.DBD_SearchAvailability

  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select SearchStatType, sum(coalesce(SearchStat,0)) as SearchStat 
from SearchStatsSummary
inner join SearchStatTypes on SearchStatsSummary.SearchStatTypeID = 
SearchStatTypes.SearchStatTypeID
where (rank != -1 or SearchStatTypes.SearchStatTypeID = 11) and datediff(mi,DateAdded,getdate()) < 60
group by SearchStatType, Rank
order by Rank
GO


GRANT EXECUTE ON [DBD_SearchAvailability] TO ExecuteOnlyRole

GO
