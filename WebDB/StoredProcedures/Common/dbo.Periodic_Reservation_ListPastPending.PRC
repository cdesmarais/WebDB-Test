if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Periodic_Reservation_ListPastPending]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Periodic_Reservation_ListPastPending]
GO

CREATE Procedure dbo.Periodic_Reservation_ListPastPending
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @now datetime
select @now= getdate() + 6 / 24.0 -- convert local (Central) time to GMT
SELECT Reservation.RStateID AS ReservationState,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    Reservation.ConfNumber AS ConfirmationNumber,
    Customer.CustID AS UserID,
    Reservation.ShiftDate AS ReservationDate,
    --CASE Version WHEN 'D1.00' THEN 2 WHEN '1.0' THEN 1 ELSE 0 END AS Version
    2 AS Version
    --Use for future version issues
FROM Reservation 
INNER JOIN Restaurant r 
ON Reservation.RID = r.RID 
INNER JOIN TimeZone tz
ON r.TZID = tz.TZID 
INNER JOIN
ERBRestaurant 
ON r.RID = ERBRestaurant.RID 
INNER JOIN Customer 
ON Reservation.CustID = Customer.CustID
WHERE (Reservation.RStateID = 1)
and 2 + Reservation.ResTime + case
when (2 + Reservation.ResTime) < 4 / 24.0
then Reservation.ShiftDate + 1 else Reservation.ShiftDate
end - tz._offsetHR / 24.0 < @now - 1.0 -- allow 24 hours slack

GO

GRANT EXECUTE ON [Periodic_Reservation_ListPastPending] TO ExecuteOnlyRole

GO
