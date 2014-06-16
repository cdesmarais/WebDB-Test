-- Drop the earlier version if necessary
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobComputeRestaurantCoverTotals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobComputeRestaurantCoverTotals]
GO

-- Create the proc
CREATE PROCEDURE dbo.JobComputeRestaurantCoverTotals

AS
--  JobComputeRestaurantCoverTotals.PRC
--  Updates RestaurantCoverCounts table periodically with rolling Standard Cover totals
--  mmc 3/12/09 TT 28244

-- get a timetamp for the LastComputedDate for this run
DECLARE @ComputeDate DateTime
SET @ComputeDate = GETDATE()

-- set the "count from" date
DECLARE @IntervalLengthDays INT
SET @IntervalLengthDays = 30

-- FromDate is this date minus N days
DECLARE @FromDate DateTime
SET @FromDate = DATEADD(day, (-1 * @IntervalLengthDays), @ComputeDate)

-- Compute the standard, seated cover totals per RID	
SELECT	r.RID,
		SUM(r.BillableSize) AS 'TotalSeatedStandardCovers',
		@ComputeDate AS 'LastComputedDate'
FROM	ReservationVW r
WHERE	r.ShiftDate >= @FromDate 
 AND	r.ShiftDate <= @ComputeDate 
 AND	r.RStateID IN (2,5,6,7) AND -- Assumed Seated, Seated, Disputed, Disputed Seated
		r.BillingType = 'OTReso'
GROUP BY r.RID

GO

-- Ensure proper permissions
GRANT EXECUTE ON [JobComputeRestaurantCoverTotals] TO ExecuteOnlyRole

GO

