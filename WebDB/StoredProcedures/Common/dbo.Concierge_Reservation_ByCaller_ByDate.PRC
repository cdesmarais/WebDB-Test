if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_ByCaller_ByDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_ByCaller_ByDate]
GO

CREATE Procedure dbo.Concierge_Reservation_ByCaller_ByDate
 (
  @UserID int,
  @Date datetime
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT Reservation.ShiftDate AS ResDate,
	 Reservation.ResTime AS ResTime,
	 CallerCustomer.LName + ',' + CallerCustomer.FName AS GuestName,
	 r.RName AS RestaurantName,
	 r.Phone AS ContactPhone,
	 Reservation.PartySize AS PartySize,
	 r.RID AS RestaurantID,
	 Reservation.ResID AS ReservationID
FROM Reservation 
INNER JOIN CallerCustomer 
ON Reservation.CustID=CallerCustomer.CustID
INNER JOIN RestaurantVW r
ON Reservation.RID=r.RID
 WHERE Reservation.CallerID = @UserID 
 and CONVERT(nvarchar,Reservation.ShiftDate,102) = CONVERT(nvarchar,@Date,102)
 and Reservation.RStateID = 1
 ORDER BY 1,2
 
GO

GRANT EXECUTE ON [Concierge_Reservation_ByCaller_ByDate] TO ExecuteOnlyRole

GO
