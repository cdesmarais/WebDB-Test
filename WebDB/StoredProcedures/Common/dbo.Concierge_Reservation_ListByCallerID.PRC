if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_ListByCallerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_ListByCallerID]
GO

CREATE Procedure dbo.Concierge_Reservation_ListByCallerID
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @dt datetime
,@date nvarchar(11)
,@time nvarchar(11)

select @dt= getdate() + 6 / 24.0 -- Adjust for servers in Central time.

SELECT Reservation.ResID AS ResID,
    Reservation.ShiftDate + 2 + Reservation.ResTime AS ReservationDateTime,
     r.RID AS RestaurantID,
    r.RName AS RestaurantName,r.City,
    r.State,
    Reservation.RStateID AS ReservationState,
    tz._offsetHR
FROM Reservation 
INNER JOIN RestaurantVW r 
ON  Reservation.RID = r.RID 
INNER JOIN  TimeZone tz 
ON   r.TZID = tz.TZID
WHERE (Reservation.CallerID = @UserID) 
AND      (Reservation.RStateID = 1)
AND (convert(nvarchar,Reservation.ShiftDate,102) > convert(nvarchar,@dt + tz._offsetHR / 24.0,102)
OR (convert(nvarchar,Reservation.ShiftDate,102) = convert(nvarchar,@dt + tz._offsetHR / 24.0,102)  AND convert(nvarchar,Reservation.ResTime,108) >= convert(nvarchar,@dt + tz._offsetHR / 24.0,108)))

GO

GRANT EXECUTE ON [Concierge_Reservation_ListByCallerID] TO ExecuteOnlyRole

GO
