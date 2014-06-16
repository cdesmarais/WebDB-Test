if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResoCoverCountsAndClosedDaysForRIDDateRange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResoCoverCountsAndClosedDaysForRIDDateRange]
GO

CREATE Procedure dbo.OTConGetResoCoverCountsAndClosedDaysForRIDDateRange

@RID	INT,
@StartDate	DATE,
@EndDate	DATE,
@ClosedDates  ClosedDaySet READONLY,
@ShiftData	  ShiftDataSetwID READONLY

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Create a Table variable to hold all the reso counts and the closed days that have resos
DECLARE @ResosAndMatchingClosedDays TABLE
(
	ShiftDate	DATETIME,
	TotalResos	INT,
	TotalCovers	INT,
	BreakfastResos INT,
	BreakfastCovers INT,
	LunchResos INT,
	LunchCovers INT,
	DinnerResos INT,
	DinnerCovers INT,
	IsClosed BIT,
	ClosedDayNote	NVARCHAR(128)
)

-- populate the table var
INSERT INTO @ResosAndMatchingClosedDays (ShiftDate, TotalResos, TotalCovers, BreakfastResos, BreakfastCovers,
						                            LunchResos, LunchCovers, DinnerResos, DinnerCovers, IsClosed, ClosedDayNote)
	SELECT	CAST(r.ShiftDate AS DATE) AS ShiftDate,
			COUNT(r.ResID) AS TotalResos, 
			SUM(r.PartySize) AS TotalCovers,
			SUM(CASE WHEN sd.ShiftTypeID = 1 THEN 1 ELSE 0 END) AS BreakfastResos,
			SUM(CASE WHEN sd.ShiftTypeID = 1 THEN PartySize ELSE 0 END) as BreakfastCovers,
			SUM(CASE WHEN sd.ShiftTypeID = 2 THEN 1 ELSE 0 END) AS LunchResos,
			SUM(CASE WHEN sd.ShiftTypeID = 2 THEN PartySize ELSE 0 END) as LunchCovers,
			SUM(CASE WHEN sd.ShiftTypeID = 3 THEN 1 ELSE 0 END) AS DinnerResos,
			SUM(CASE WHEN sd.ShiftTypeID = 3 THEN PartySize ELSE 0 END) as DinnerCovers,
			COALESCE(cd.IsClosed, 0) AS IsClosed,
			cd.Note AS 'ClosedDayNote'
	FROM	Reservation r
		LEFT JOIN @ShiftData sd ON CAST(r.ResTime AS TIME) BETWEEN CAST(sd.StartTime AS TIME) AND CAST(sd.EndTime AS TIME)
		LEFT JOIN @ClosedDates cd ON cd.ScheduleDate = CAST(r.ShiftDate AS DATE)
	WHERE	r.RID = @RID
	 AND	r.ShiftDate BETWEEN @StartDate AND @EndDate
	 AND	r.RStateID  IN (1,2,5,7) -- include Pending,Seated, Assumed Seated, and Seated Disputed
	GROUP BY CAST(r.ShiftDate AS DATE), cd.IsClosed, cd.Note
	-- Force the compiler to optimize based on statistics, not based on first execution
	OPTION ( OPTIMIZE FOR (@RID UNKNOWN, @StartDate UNKNOWN, @EndDate UNKNOWN) );
	
-- Now combine these results with the Closed days that don't have resos

	SELECT	*
	FROM	@ResosAndMatchingClosedDays

UNION

	SELECT	ScheduleDate AS ShiftDate,
			0 AS TotalResos,
			0 AS TotalCovers,
			0 AS BreakfastResos,
			0 AS BreakfastCovers,
			0 AS LunchResos,
			0 AS LunchCovers,
			0 AS DinnerResos,
			0 AS DinnerCovers,
			IsClosed,
			Note AS 'ClosedDayNote'
	FROM	@ClosedDates cd
	WHERE	cd.ScheduleDate NOT IN (SELECT ShiftDate FROM @ResosAndMatchingClosedDays)
	
	ORDER BY ShiftDate

GO

GRANT EXECUTE ON [OTConGetResoCoverCountsAndClosedDaysForRIDDateRange] TO ConsoleExecuteRole

GO

