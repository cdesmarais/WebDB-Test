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

-- everything goes in a transaction
BEGIN TRANSACTION

-- get a timetamp for the LastComputedDate for this run
DECLARE @ComputeDate DateTime
SET @ComputeDate = GETDATE()

-- set the "count from" date
DECLARE @IntervalLengthDays INT
SET @IntervalLengthDays = 30

-- FromDate is this date minus N days
DECLARE @FromDate DateTime
SET @FromDate = DATEADD(day, (-1 * @IntervalLengthDays), @ComputeDate)

-- TODO Q:  update/insert record by record, or clear out everything?  Let's try the latter
-- clear out existing records
DELETE	FROM RestaurantCoverCounts

-- Insert new values
INSERT INTO RestaurantCoverCounts (RID, TotalSeatedStandardCovers, LastComputedDate)
	SELECT	r.RID,
			SUM(r.SeatedSize),
			@ComputeDate
	FROM	ReservationVW r
	WHERE	r.ShiftDate >= @FromDate AND
			r.ShiftDate <= @ComputeDate AND
			r.RStateID IN (2,5) AND -- Assumed Seated, Seated
			r.ResPoints IN (0, 100) AND -- Anon or Standard
			r.BillingType = 'OTReso'
	GROUP BY r.RID

IF @@ERROR <> 0
	BEGIN
	-- something's wrong, undo everything
	ROLLBACK TRANSACTION
	RAISERROR ('Error %d encountered during JobComputeRestaurantCoverTotals', 16, 1, @@ERROR)
	END
		
-- All good
COMMIT TRANSACTION

GO

-- Ensure proper permissions
GRANT EXECUTE ON [JobComputeRestaurantCoverTotals] TO ExecuteOnlyRole

GO

