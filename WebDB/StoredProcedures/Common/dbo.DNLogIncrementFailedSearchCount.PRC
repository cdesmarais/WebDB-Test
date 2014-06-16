if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogIncrementFailedSearchCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogIncrementFailedSearchCount]
GO

CREATE PROCEDURE dbo.DNLogIncrementFailedSearchCount
(
   	@nRID int,
   	@nBlockedDay int,
	@nNoTimes int,
	@nConnectivity int,
	@nDayInAdvance int,
	@nCutOffTime int
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

BEGIN

if NOT EXISTS(Select RID from FailedSearchCount where RID = @nRID) 
   BEGIN

	INSERT INTO FailedSearchCount (RID,BlockedDay,NoTimes,Connectivity,DayInAdvance,CutOffTime,LastCounterResetDate,LastCounterIncrementedDate)
		VALUES(@nRID,@nBlockedDay,@nNoTimes,@nConnectivity,@nDayInAdvance,@nCutOffTime,(GetDate()),(GetDate()))
   END
ELSE 
   BEGIN
	DECLARE @nBlockedDayCount int
	DECLARE @nNoTimesCount int
	DECLARE @nConnectivityCount int
	DECLARE @nDayInAdvanceCount int
	DECLARE @nCutOffTimeCount int

	SELECT @nBlockedDayCount = fs.BlockedDay,
		@nNoTimesCount = fs.NoTimes,
		@nConnectivityCount = fs.Connectivity,
		@nDayInAdvanceCount = fs.DayInAdvance,
		@nCutOffTimeCount = fs.CutOffTime
	 FROM FailedSearchCount AS fs WHERE fs.RID = @nRID

	UPDATE FailedSearchCount SET
		 FailedSearchCount.BlockedDay = @nBlockedDayCount + @nBlockedDay,
		 FailedSearchCount.NoTimes = @nNoTimesCount + @nNoTimes,
		 FailedSearchCount.Connectivity = @nConnectivityCount + @nConnectivity,
		 FailedSearchCount.DayInAdvance = @nDayInAdvanceCount + @nDayInAdvance,
		 FailedSearchCount.CutOffTime = @nCutOffTimeCount + @nCutOffTime
   END
END

GO

GRANT EXECUTE ON [DNLogIncrementFailedSearchCount] TO ExecuteOnlyRole

GO
