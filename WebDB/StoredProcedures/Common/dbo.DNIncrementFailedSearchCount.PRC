if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNIncrementFailedSearchCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNIncrementFailedSearchCount]
GO


CREATE PROCEDURE dbo.DNIncrementFailedSearchCount
(
   	@nRestaurantID int,
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

-- Check for existence of restaurant id
if NOT EXISTS(Select RID from FailedSearchCount where RID = @nRestaurantID) 
   BEGIN


	INSERT INTO FailedSearchCount (RID, BlockedDay, NoTimes, Connectivity, DayInAdvance,CutOffTime,LastCounterResetDate,LastCounterIncrementedDate)
		VALUES(@nRestaurantID,@nBlockedDay, @nNoTimes, @nConnectivity, @nDayInAdvance, @nCutOffTime, (GetDate()),(GetDate()))
   END
ELSE -- Counter for this restaurant already exists
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
	 FROM FailedSearchCount AS fs WHERE fs.RID = @nRestaurantID

	UPDATE FailedSearchCount SET
		 FailedSearchCount.BlockedDay = @nBlockedDayCount + @nBlockedDay,
		 FailedSearchCount.NoTimes = @nNoTimesCount + @nNoTimes,
		 FailedSearchCount.Connectivity = @nConnectivityCount + @nConnectivity,
		 FailedSearchCount.DayInAdvance = @nDayInAdvanceCount + @nDayInAdvance,
		 FailedSearchCount.CutOffTime = @nCutOffTimeCount + @nCutOffTime
		
   END
END

GO


GRANT EXECUTE ON [DNIncrementFailedSearchCount] TO ExecuteOnlyRole

GO
