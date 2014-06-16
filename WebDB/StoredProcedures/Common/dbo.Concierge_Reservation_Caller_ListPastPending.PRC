if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_ListPastPending]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_ListPastPending]
GO

CREATE Procedure dbo.Concierge_Reservation_Caller_ListPastPending
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @now datetime
select @now= getdate() + 6 / 24.0 -- Convert local (Central) time to GMT.
SELECT Reservation.RStateID AS ReservationState,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    Reservation.ConfNumber AS ConfirmationNumber,
    CallerCustomer.CustID AS UserID,
    Reservation.ShiftDate AS ReservationDate,
    CASE Version WHEN 'D1.00' THEN 2 WHEN '1.0' THEN 1 ELSE 0 END AS Version
FROM Reservation 
INNER JOIN   Restaurant r
ON   Reservation.RID = r.RID 
INNER JOIN  TimeZone tz
ON  r.TZID = tz.TZID 
INNER JOIN  ERBRestaurant 
ON   r.RID = ERBRestaurant.RID 
INNER JOIN     CallerCustomer 
ON    Reservation.CustID = CallerCustomer.CustID
WHERE (Reservation.RStateID = 1)
and 2 + Reservation.ResTime + case
when (2 + Reservation.ResTime) < 4 / 24.0
then Reservation.ShiftDate + 1 else Reservation.ShiftDate
end - tz._offsetHR / 24.0 < @now - 1.0 -- Allow 24 hours of slack.

GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_ListPastPending] TO ExecuteOnlyRole

GO
