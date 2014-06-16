if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_ByCompany]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_ByCompany]
GO

CREATE Procedure dbo.Concierge_Reservation_ByCompany
(
  @HotelID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
/*
SELECT Reservation.ShiftDate AS ResDate FROM Reservation
WHERE (Reservation.CompanyID = @HotelID) 
and Reservation.RStateID = 1
*/


SELECT Reservation.ShiftDate AS ResDate,
	 Reservation.ResTime AS ResTime,
	 CallerCustomer.LName + ',' + CallerCustomer.FName AS GuestName,
	 r.RName AS RestaurantName,
	 r.Phone AS ContactPhone,
	 Reservation.PartySize AS PartySize,
	 r.RID AS RestaurantID,
	 Reservation.ResID AS ReservationID,
	 Caller.FName + ' ' + Caller.LName AS CallerName,
	 Reservation.ShiftDate AS ReservationDate,
	 Reservation.ResPoints as Points_For_Reservation
FROM Reservation
INNER JOIN Caller 
ON Reservation.CallerID=Caller.CallerID
INNER JOIN CallerCustomer 
ON Reservation.CustID=CallerCustomer.CustID
INNER JOIN RestaurantVW r 
ON Reservation.RID=r.RID
WHERE Reservation.CompanyID = @HotelID
and Reservation.RStateID = 1
and CONVERT(nvarchar,Reservation.ShiftDate,102) >= CONVERT(nvarchar,getdate(),102)
--ORDER BY 1,2


GO

GRANT EXECUTE ON [Concierge_Reservation_ByCompany] TO ExecuteOnlyRole

GO
