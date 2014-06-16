if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procOTConValidateShift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procOTConValidateShift]
GO


CREATE PROCEDURE dbo.procOTConValidateShift
(
	@RID						INT,
	@OldStartTime				TIME,
	@OldEndTime					TIME,
	@NewStartTime				TIME,
	@NewEndTime					TIME,
	@DaysOfWeek					VARBINARY(1),  -- Days of the week the shift is OPEN
	@MaxPartySize				INT,
	@MaxCoversAllowed			INT
)

AS
--
-- Checks resos for the given RID out 1 year and reports any dates that have resos that
-- 1) Have a res time that falls before the givenStartTime of after the given EndTime
-- 2) Have a party size that exceeds the MaxPartySize
-- 3) Fall on a day that's Closed (i.e. not an ON bit in the DaysOfWeek bit vector
--    The DOW mask mechanism works like this:  the input @DayOfWeek mask refects OPEN days,Sun-Sat like this (MSB not used):
--    xSMTWRFS
--    The DATEPART(dw,...) fn returns the day of the week for the given date, Sun=1,..Sat=7
--    To compare the reso DOW to the input bit array, calculate the "inverse" DOW (e.g. Sun=7, Sat = 1) and then
--    use the POWER(2,n) function to select the corresponding bit to test.  If the Reso DOW bit is on (exactly one always will be),
--    but the corresponding bitmask bit is OFF, then that's a violation
-- 4) Have cover counts that exceed the specified maximum

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Use DATETIME for validation boundries, to leverage ShiftDate partitioning without CASTs
DECLARE @CurrentDateTimeAtRestaurant	DATETIME
DECLARE @CurrentDateAtRestaurant		DATETIME
DECLARE @OneYearFromCurrentDate			DATETIME

-- get the current date at the restaurant
SELECT		@CurrentDateTimeAtRestaurant = tz.CurrentLocalTime 
FROM		TimezoneVW tz
INNER JOIN	RestaurantVW r ON r.TZID = tz.tzid and r.RID = @RID

IF @CurrentDateTimeAtRestaurant IS NULL
BEGIN
	DECLARE @ERR NVARCHAR(1024)
	SET @ERR = 'Unable to find TimeZone info for RID ' + CAST(@RID AS NVARCHAR(6))
	RAISERROR(@ERR, 16, 1)
END

-- now get just the date parts
SET @CurrentDateAtRestaurant = CAST(CAST(@CurrentDateTimeAtRestaurant AS DATE) AS DATETIME) -- strip off the Time part, i.e. check starting from midnight last night
SET @OneYearFromCurrentDate = DATEADD(day, 365, @CurrentDateAtRestaurant)


SELECT		CAST(ShiftDate AS DATE) AS ShiftDate, 
			SUM(CASE WHEN (@DaysOfWeek & POWER(2, 7-DATEPART(dw, ShiftDate)) > 0) -- reso day is ON
					 AND  ((CAST(ResTime AS TIME) >= @OldStartTime AND CAST(ResTime AS TIME) < @NewStartTime)-- later start time
							OR (CAST(ResTime AS TIME) > @NewEndTime AND CAST(ResTime AS TIME) <= @OldEndTime)) -- earlier end time 
				  THEN 1 ELSE 0 END) AS 'ShiftTimeErrors',
			SUM(CASE WHEN (PartySize > @MaxPartySize)
					 AND  CAST(ResTime AS TIME) BETWEEN @NewStartTime AND @NewEndTime  THEN 1 ELSE 0 END) AS 'PartySizeErrors', -- reso falls between proper start/end times
			SUM(CASE WHEN CAST(ResTime AS TIME) BETWEEN @NewStartTime AND @NewEndTime
					 AND (@DaysOfWeek & POWER(2, 7-DATEPART(dw, ShiftDate)) = 0)THEN 1 ELSE 0 END) AS 'ClosedDayOfWeekErrors', -- bitwise AND with DOW mask and bit for reso day is OFF
            CASE WHEN 
				SUM(CASE WHEN 
						((@DaysOfWeek & POWER(2, 7-DATEPART(dw, ShiftDate)) > 0) -- reso day is ON
                                    AND CAST(ResTime AS TIME) BETWEEN @NewStartTime AND @NewEndTime)
                        THEN Partysize 
                        ELSE 0
                        END) 
                        > @MaxCoversAllowed THEN 1 ELSE 0 
                  END AS 'OverbookingErrors'  
FROM		Reservation
WHERE		RID = @RID
 AND		ShiftDate BETWEEN @CurrentDateAtRestaurant AND @OneYearFromCurrentDate
 AND		RStateID = 1 -- only pending resos
GROUP BY	ShiftDate
ORDER BY	ShiftDate
GO

GRANT EXECUTE ON [procOTConValidateShift] TO ConsoleExecuteRole

GO
