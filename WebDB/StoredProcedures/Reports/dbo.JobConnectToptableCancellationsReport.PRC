if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobConnectToptableCancellationsReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobConnectToptableCancellationsReport]
GO

CREATE PROCEDURE dbo.[JobConnectToptableCancellationsReport]
@TodaysDate		DATETIME = NULL

AS
-- 
-- Count cancellations from toptable Connect restaurants for 7 days up to and including the 
-- run date.  

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Use the current date if none is specified in the proc input
IF @TodaysDate IS NULL
BEGIN
	SET @TodaysDate = GETDATE()
END

-- get the lower-bound of ResLogIDs to search
DECLARE @LookbackCount INT = 5000000  -- go back 5M records
DECLARE @StartingResLogID INT

SELECT  TOP 1 @StartingResLogID = ResLogID 
FROM	ReservationLog WITH (NOLOCK) 
WHERE	ResLogID < ((SELECT MAX(ResLogID) from ReservationLog WITH (NOLOCK)) - @LookbackCount)
ORDER BY 1 DESC


SELECT	r.RID, 
		rv.RName AS 'Restaurant Name',
		r.ReservationID AS 'Reservation ID',
		r.FirstName AS 'First Name',
		r.LastName AS 'Last Name',
		r.PartySize,
		CAST(r.ShiftDate AS DATE) AS 'Shift Date',
		CAST(r.ReservationTime AS TIME(0)) AS 'Reservation Time',
		CASE 
			WHEN r.ReservationStateID = 3 THEN 'Cancelled by Diner'
			WHEN r.ReservationStateID = 8 THEN 'Cancelled by Restaurant'
			WHEN r.ReservationStateID = 9 THEN 'Disputed Cancellation'
			ELSE 'Other'
		END AS 'Cancellation Type',
		CAST(r.DateMade AS DATE) AS 'Date Made',
		CAST(DATEADD(MI, tz.ServerToLocalOffsetMi,cancelLog.UpdateDT) AS DATE) AS 'Date Cancelled'			-- use Restaurant time for DateCancelled
FROM	OTConReservationDetailVW r 

INNER JOIN	RestaurantVW rv
ON			r.RID = rv.RID

INNER JOIN	TimezoneVW tz
ON			tz.TZID = rv.TZID

INNER JOIN	ReservationLog cancelLog
ON			cancelLog.ResID = r.ReservationID
AND			cancelLog.RStateID IN ( 3, 8, 9 )		-- filter RState here, too.  May result in multiple records but probably OK

WHERE		cancelLog.ResLogID > @StartingResLogID	-- Use the lower bound of the ResLogID because ResLog.UpdateDT is not indexed.
AND			rv.RestaurantType = 'A'					-- connect restaurants only
AND			rv.BrandID = 2							-- toptable only
AND			r.ReservationStateID IN (3, 8, 9)		-- cancelled diner, cancelled restaurant, cancelled disputed	
AND			CAST(DATEADD(MI, tz.ServerToLocalOffsetMi,cancelLog.UpdateDT) AS DATE) > (@TodaysDate - 7)
ORDER BY	r.RID, r.ReservationID

GO

GRANT EXECUTE ON [JobConnectToptableCancellationsReport] TO ExecuteOnlyRole

-- need this?
GRANT EXECUTE ON [JobConnectToptableCancellationsReport] TO DTR_User
GO


