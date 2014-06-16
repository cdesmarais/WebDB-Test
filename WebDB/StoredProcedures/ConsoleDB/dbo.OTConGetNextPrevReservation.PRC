if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetNextPrevReservation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetNextPrevReservation]
GO

--
-- Gets the next/previous  reservation given a specific resoID
-- 

CREATE Procedure dbo.OTConGetNextPrevReservation

@RID			INT, -- not strictly necessary (ResIDs are unique) but included for extra security
@ReservationID	INT,
@NextOrPrev		INT  -- < 0 means previous, >= 0 means next
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- a table to hold all resos for the day. Add a row index
DECLARE @ResosForDay TABLE
(
	RowID INT IDENTITY (1,1),
	ResTime	TIME,
	ResID	INT
)

-- first, get all resos for the same day as the given reso.  
INSERT INTO @ResosForDay
SELECT CAST(r.ResTime AS TIME) AS ResTime,
			r.ResID 
FROM Reservation r
INNER JOIN Reservation r2 ON r2.ResID = @ReservationID AND r2.ShiftDate = r.ShiftDate
WHERE r.RID = @RID
  AND r.RStateID in (1,2,5,6)	-- only certain statuses
ORDER BY r.ResTime ASC, r.ResID ASC

-- find the original reso
DECLARE @CurrentResoRowID INT
DECLARE @RowIDOfInterest INT
DECLARE @ResIDOfInterest INT

-- initialize to values that are easy to test later
SET @ResIDOfInterest = -1

-- get the index of the current reso
SELECT	@CurrentResoRowID = RowID
FROM	@ResosForDay
WHERE	ResID = @ReservationID

-- find the next/prev reso, if it exists
IF (@NextOrPrev < 0)
	BEGIN -- Find Previous reso
		SELECT	@ResIDOfInterest = ResID
		FROM	@ResosForDay
		WHERE	RowID = @CurrentResoRowID - 1
	END
ELSE
	BEGIN -- Find Next Reso
		SELECT	@ResIDOfInterest = ResID
		FROM	@ResosForDay
		WHERE	RowID = @CurrentResoRowID + 1
	END
	
-- No such reso, just return
if (@ResIDOfInterest = -1)
BEGIN
	RETURN
END

-- return the requested reso
EXEC procOTConGetReservationByID @RID, @ResIDOfInterest

GO

GRANT EXECUTE ON [OTConGetNextPrevReservation] TO ConsoleExecuteRole

GO

