if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_GetERBByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_GetERBByID]
GO

CREATE Procedure dbo.Concierge_Reservation_Caller_GetERBByID
 (
  @ReservationID int
 )
As

set transaction isolation level read uncommitted

SELECT Reservation.ConfNumber AS Confirmation,
    Reservation.ShiftDate + 2 + Reservation.ResTime AS ResDateTime,
    Reservation.PartySize AS PartySize,
    CallerCustomer.CallerID AS UserID,
    CallerCustomer.FName AS FirstName,
    CallerCustomer.LName AS LastName,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    r.RName AS RestaurantName,
    r.RID AS RestaurantID,
    left(r.Phone,3) + '-' + left(right(r.Phone,7),3) + '-' + right(r.Phone,4) AS RestaurantPhone,
    Reservation.ContactPhone As ContactPhone,
    'webdev@opentable.com' As AlertDestination,
   'webdev@opentable.com' As AlertBCC,
   coalesce(Reservation.CompanyID,0) as CompanyID,
   Reservation.LargeParty as Large_Party
FROM Reservation 
INNER JOIN CallerCustomer 
ON Reservation.CustID = CallerCustomer.CustID 
INNER JOIN RestaurantVW r
ON Reservation.RID = r.RID 
INNER JOIN ERBRestaurant 
ON r.RID = ERBRestaurant.RID
WHERE (Reservation.ResID = @ReservationID) 
and r.RestStateID = 1

GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_GetERBByID] TO ExecuteOnlyRole

GO
