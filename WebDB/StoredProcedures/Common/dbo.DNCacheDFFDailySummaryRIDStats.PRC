if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDFFDailySummaryRIDStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDFFDailySummaryRIDStats]
GO

CREATE PROCEDURE dbo.DNCacheDFFDailySummaryRIDStats
 As

SET NOCOUNT ON

set transaction isolation level read uncommitted  -- Don't read from DFFDailySummaryRIDStatsHolding table while otservice is updating it from MySQL

Select		WebRID
			,TotalDffs
			,Cat_1
			,Cat_4
			,Cat_5
			,Cat_6
			,Cat_7
			,Cat_8
			,Cat_9
			,Cat_10
			,Cat_11
			,Cat_13
			,Cat_14
			,Cat_16
			,Cat_17
			,Cat_18
			,BlackListFlag
			,AverageOverallRating					
from		DFFDailySummaryRIDStatsHolding
order by 	WebRID
GO

GRANT EXECUTE ON [DNCacheDFFDailySummaryRIDStats] TO ExecuteOnlyRole

GO
