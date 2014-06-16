if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetReservationsByRidDateRange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetReservationsByRidDateRange]
GO

--
-- Gets all the reservations for the given RID and date range
-- Used primarily by EmailManager for ConsoleEmails
-- 

CREATE Procedure dbo.GetReservationsByRidDateRange

@RID				INT,
@StartDate			DATE,
@EndDate			DATE
As

SET NOCOUNT ON
set transaction ISOLATION LEVEL read UNCOMMITTED

-- Use DateTime objects to avoid casts of r.ShiftDate
DECLARE @StartDateTime	DATETIME
DECLARE @EndDateTime	DATETIME

SET @StartDateTime = @StartDate 
SET @EndDateTime = @EndDate

SELECT	r.RID,
		ReservationID,
		ReservationDate,
		ReservationTime,
		r.PartySize,
		r.FirstName AS DinerFName,  -- consider changing caller to avoid name change
		r.LastName AS DinerLName, -- consider changing caller to avoid name change
		r.ContactPhone,
		r.Notes,
		r.DateMade,
		r.FirstName_Phonetic AS DinerFNamePhonetic,
		r.LastName_Phonetic AS DinerLNamePhonetic,
		r.OfferDescription,
		r.RedemptionCover,
		r.RedemptionDescription
FROM	OTConReservationDetailVW r
WHERE	r.RID = @RID
 AND	r.ReservationStateID  IN (1,2,5) -- include Pending,Seated, Assumed Seated, and Seated Disputed
 AND	r.ShiftDate BETWEEN @StartDateTime AND @EndDateTime -- use ShiftDate to preserve Reservation table partitioning
ORDER BY ReservationDate ASC, ReservationTime ASC

GO

GRANT EXECUTE ON [GetReservationsByRidDateRange] TO ExecuteOnlyRole

GO

