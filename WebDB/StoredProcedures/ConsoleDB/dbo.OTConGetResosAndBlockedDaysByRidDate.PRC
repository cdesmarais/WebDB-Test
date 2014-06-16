if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResosAndBlockedDaysByRidDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResosAndBlockedDaysByRidDate]
GO


CREATE PROCEDURE dbo.OTConGetResosAndBlockedDaysByRidDate
(
	@RID				INT,
	@DisplayDate		DATETIME,
	@ShiftData			OTCShiftDataSetV2 READONLY,
	@BlockedTimes		OTCBlockedTimeSet READONLY,
	@StatusIDList		NVARCHAR(128)  -- comma-delimited list of ResoStatusIDs to include
)

AS

-- create a table var to hold the results
DECLARE @AllData TABLE
(
		RID									INT,
		ReservationID						INT,
		ReservationStateID					INT,
		ReservationDate						DATE,
		ReservationTime						TIME,
		PartySize							INT,
		FirstName							NVARCHAR(40),
		LastName							NVARCHAR(40),
		Email								NVARCHAR(75),
		PhoneType							NVARCHAR(60),
		ContactPhone						NVARCHAR(24),
		Notes								NVARCHAR(999),
		DateMade							DATETIME,
		ConfNumber							INT,
		ServerTimeToLocalTimeOffsetMinutes	INT,
		ShiftName							NVARCHAR(256),
		ShiftTypeID							INT,
		ReservationState					NVARCHAR(20),
		FirstName_Phonetic					NVARCHAR(40),
		LastName_Phonetic					NVARCHAR(40),
		OfferDescription					NVARCHAR(500),
		RedemptionDescription				NVARCHAR(500),
		RedemptionCover						INT,
		IsBlocked							BIT
		)

-- single date, but all times (add 1439 minutes so that the end time is 23:59:00)
DECLARE @EndOfDisplayDate DATETIME = DATEADD(MINUTE, 1439, @DisplayDate)

--  first insert the resos
INSERT INTO @AllData
	EXEC procGetReservationsByRidDateRange_V3 @RID, @DisplayDate, @EndOfDisplayDate, @ShiftData, @StatusIDList
	
-- now insert the blocked time data
INSERT INTO @AllData (RID, ReservationDate, ReservationTime, ShiftTypeID, IsBlocked)
	SELECT	@RID, @DisplayDate, BlockedTime, s.ShiftTypeID, 1
	FROM	@BlockedTimes b
	INNER JOIN @ShiftData s
	ON		   b.BlockedTime BETWEEN s.StartTime AND s.EndTime

-- return the whole shebang, sorted
SELECT		*
FROM		@AllData
ORDER BY	ReservationTime
GO

GRANT EXECUTE ON OTConGetResosAndBlockedDaysByRidDate TO ConsoleExecuteRole

GO
