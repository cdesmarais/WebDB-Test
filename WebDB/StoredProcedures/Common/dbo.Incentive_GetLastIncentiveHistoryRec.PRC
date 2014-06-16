
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetLastIncentiveHistoryRec]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetLastIncentiveHistoryRec]
GO


CREATE procedure [dbo].[Incentive_GetLastIncentiveHistoryRec]
(
	@RID int
)
as

SELECT max(IncHistID) as LastHistID
FROM IncentiveHistory
WHERE RID = @RID

Go

GRANT EXECUTE ON [Incentive_GetLastIncentiveHistoryRec] TO ExecuteOnlyRole


GO

