if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetReservationsByRidDateRange_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetReservationsByRidDateRange_V2]
GO

--
-- Gets all the reservations for the given RID and date range, regardless of ReservationState
-- Retrieves ShiftName from the input datatable

CREATE Procedure dbo.procGetReservationsByRidDateRange_V2

@RID				INT,
@StartDate			DATETIME,
@EndDate			DATETIME,
@ShiftData			OTCShiftDataSet READONLY,
@StatusIDList		NVARCHAR(128)  -- list of ResoStatusIDs to include

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @StartDateOnly datetime
declare @EndDateOnly datetime

set @StartDateOnly = CONVERT(datetime,CAST(@StartDate as Date))
set @EndDateOnly = CONVERT(datetime,CAST(@EndDate as Date))

-- Now select against the status table
SELECT	RID,
		ReservationID,
		ReservationStateID,
		ReservationDate,
		ReservationTime,
		PartySize,
		FirstName,
		LastName,
		Email,
		PhoneType,
		ContactPhone,
		Notes,
		DateMade,
		ConfNumber,
		ServerTimeToLocalTimeOffsetMinutes,
		s.ShiftName,
		s.ShiftTypeID,
		r.ReservationState
FROM	OTConReservationDetailVW r
	INNER JOIN  fStringsToTab(@StatusIDList, ',') res ON r.ReservationStateID = res.StringValues
	LEFT JOIN @ShiftData s ON r.ReservationTime BETWEEN CAST(s.StartTime AS TIME) AND CAST(s.EndTime AS TIME)
WHERE	r.RID = @RID
 AND	r.ShiftDate >= @StartDateOnly 
 AND	r.ShiftDate  <= @EndDateOnly -- Reduce set by Reservation Partion Key (this is critical for performance)
 AND    ReservationTime >= CAST(@StartDate AS TIME)
 AND	ReservationTime <= CAST(@EndDate AS TIME)
ORDER BY  ReservationDate ASC, ReservationTime ASC, ReservationID ASC -- Use ResoID as a tiebreaker so the next/prev proc works consistently

GO

GRANT EXECUTE ON [procGetReservationsByRidDateRange_V2] TO ExecuteOnlyRole
GO

GRANT EXECUTE ON [procGetReservationsByRidDateRange_V2] TO ConsoleExecuteRole

GO

