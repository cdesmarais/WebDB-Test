if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogGetReservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogGetReservations]
GO

CREATE PROCEDURE dbo.DNLogGetReservations

AS

SELECT
rl.VisitorID,
rl.SessionID,
rl.UserID,
rl.ResID,
r.RStateID as ReservationStateID,
rl.SearchType,
rl.Registration,
rl.ReferralID,
rl.PartnerID,
rl.UserType,
rl.DateCreated as ReservationMadeDateTime,
r.ShiftDate + 2 + r.ResTime as ReservationDateTime

FROM WebSiteReservationLog as rl 
INNER JOIN Reservation as r 
ON rl.ResID = r.ResID
GO


GRANT EXECUTE ON [DNLogGetReservations] TO ExecuteOnlyRole

GO
