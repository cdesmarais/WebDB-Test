if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetReservationsByRidDateTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetReservationsByRidDateTime]
GO

--
-- Gets all the reservations for the given RID, date, and time range
-- Used primarily by EmailManager for ConsoleEmails
-- 

CREATE Procedure dbo.GetReservationsByRidDateTime

@RID				INT,
@ReservationDate	DATE,
@StartTime			TIME,
@EndTime			TIME
As

set transaction isolation level read uncommitted

-- USE ReservationDateTime to avoid CASTing r.ShiftDate
DECLARE @ReservationDateTime	DATETIME
SET @ReservationDateTime = @ReservationDate

SELECT	r.RID,
		r.ReservationID,
		r.ReservationDate,
		r.ReservationTime,
		r.PartySize,
		r.FirstName AS DinerFName,
		r.LastName AS DinerLName,
		r.ContactPhone,
		r.Notes,
		r.DateMade,
		r.FirstName_Phonetic AS DinerFNamePhonetic,
		r.LastName_Phonetic AS DinerLNamePhonetic,
		r.OfferDescription,
		r.RedemptionDescription,
		r.RedemptionCover
FROM	OTConReservationDetailVW r
WHERE	RID = @RID
 AND	r.ReservationStateID  IN (1,2,5) -- include Pending,Seated, Assumed Seated, and Seated Disputed
 AND	r.ShiftDate = @ReservationDate		-- ShiftDate is used for Reservation view partitioning
 AND	CAST(ReservationTime AS TIME) BETWEEN @StartTime AND @EndTime
ORDER	BY ReservationTime ASC

GO

GRANT EXECUTE ON [GetReservationsByRidDateTime] TO ExecuteOnlyRole

GO

