--
-- dbo.JobCountStandardRervationsByRID.PRC
-- Counts standard resos for rids and returns RID, count, and time calculated
--

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCountStandardRervationsByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCountStandardRervationsByRID]
GO

-- Create the proc
CREATE PROCEDURE dbo.JobCountStandardRervationsByRID

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- get a timetamp for the LastComputedDate for this run
DECLARE @ComputeDate DateTime
SET @ComputeDate = GETDATE()

-- set the "count from" date
DECLARE @IntervalLengthDays INT
SET @IntervalLengthDays = 30

-- FromDate is this date minus N days
DECLARE @FromDate DateTime
SET @FromDate = DATEADD(day, (-1 * @IntervalLengthDays), @ComputeDate)

-- Count the resos
SELECT	r.RID,
		SUM(r.BillableSize) AS TotalSeatedStandardCovers,
		@ComputeDate AS LastComputedDate
FROM	ReservationVW r WITH (NOLOCK) 
WHERE	r.ShiftDate BETWEEN @FromDate AND @ComputeDate
AND		r.RStateID IN (1,2,5,6,7) -- Billable states
AND		r.BillingType = 'OTReso'
GROUP BY r.RID

GO

-- Ensure proper permissions
GRANT EXECUTE ON [JobCountStandardRervationsByRID] TO ExecuteOnlyRole

GO
