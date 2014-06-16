if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogFailedSearchTotal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogFailedSearchTotal]
GO

CREATE PROCEDURE dbo.DNLogFailedSearchTotal
(
	@nRID int,
	@nResetFailedCounter int
)
AS

SET NOCOUNT ON

INSERT INTO FailedSearchTotals SELECT c.RID,c.BlockedDay,c.NoTimes,c.Connectivity,c.DayInAdvance,
	c.CutOffTime,c.LastCounterResetDate,c.LastCounterIncrementedDate FROM FailedSearchCount as c 
	/**
	INNER JOIN FailedSearchTotals as t
	ON c.RID = @nRID  
	AND (t.RID = c.RID AND t.EndDate != c.LastCounterIncrementedDate)
**/
if (@nResetFailedCounter = 1)
	UPDATE FailedSearchCount SET BlockedDay = 0,NoTimes = 0,Connectivity = 0,DayInAdvance = 0
		,CutOffTime = 0,LastCounterResetDate = (GetDate()),LastCounterIncrementedDate = (GetDate()) WHERE
		RID = @nRID
GO

GRANT EXECUTE ON [DNLogFailedSearchTotal] TO ExecuteOnlyRole

GO
