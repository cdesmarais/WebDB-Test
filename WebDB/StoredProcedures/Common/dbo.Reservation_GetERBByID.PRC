if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetERBByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetERBByID]
GO

CREATE Procedure dbo.Reservation_GetERBByID 
 ( 
  @ReservationID int,
  @CallerID int=0 
 ) 
As 

set transaction isolation level read uncommitted 
if (@CallerID=0) 
Begin 
SELECT Reservation.ConfNumber AS Confirmation,
    Reservation.ShiftDate + 2 + Reservation.ResTime AS ResDateTime,
    Reservation.PartySize AS PartySize,
    Reservation.CustID AS UserID,
    IsNull(Reservation.CallerID,0) As CallerID,
    Customer.FName AS FirstName,
    Customer.LName AS LastName,
    Customer.EMail,
    Reservation.ContactPhone as ContactPhone,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    r.RName AS RestaurantName,
    r.RID AS RestaurantID,
    r.Phone AS RestaurantPhone,
    r.Allotment as Allotment,
    --'webdev@opentable.com' as AlertDestination,
    'otcallcenter@opentable.com' as AlertDestination,
    'webdev@opentable.com' as AlertBCC,
    Reservation.LargeParty as Large_Party,ConsumerType as Consumer_Type,
	Reservation.PartnerID as Partner_ID
FROM Reservation INNER JOIN 
    Customer ON 
    Reservation.CustID = Customer.CustID INNER 
     JOIN 
    RestaurantVW r ON 
    Reservation.RID = r.RID INNER JOIN 
    ERBRestaurant ON 
    r.RID = ERBRestaurant.RID 
WHERE (Reservation.ResID = @ReservationID)  and RStateID = 1 
End if(@CallerID<>0) 
Begin 
SELECT Reservation.ConfNumber AS Confirmation,
    Reservation.ShiftDate + 2 + Reservation.ResTime AS ResDateTime,
    Reservation.PartySize AS PartySize,
    Reservation.CustID AS UserID,
    Reservation.ContactPhone as ContactPhone,
    IsNull(Reservation.CallerID,0) As CallerID,
    CallerCustomer.FName AS FirstName,
    CallerCustomer.LName AS LastName,
    CallerCustomer.EMail,
    Caller.FName AS Admin_First,
    Caller.LName AS Admin_Last,
    Caller.EMail As AdminEmail,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    r.RName AS RestaurantName,
    r.RID AS RestaurantID,
    r.Phone As RestaurantPhone,
    r.Allotment as Allotment,
    --'webdev@opentable.com' as AlertDestination,
    'otcallcenter@opentable.com' as AlertDestination,
    'webdev@opentable.com' as AlertBCC,
    Reservation.LargeParty as Large_Party,ConsumerType as Consumer_Type,Reservation.PartnerID as Partner_ID

FROM Reservation INNER JOIN 
    CallerCustomer ON 
    Reservation.CustID = CallerCustomer.CustID INNER JOIN 
    Caller ON Reservation.CallerID = Caller.CallerID INNER 
     JOIN 
    RestaurantVW r ON 
    Reservation.RID = r.RID INNER JOIN 
    ERBRestaurant ON 
    r.RID = ERBRestaurant.RID 
WHERE (Reservation.ResID = @ReservationID)  and RStateID = 1 
End

GO

GRANT EXECUTE ON [Reservation_GetERBByID] TO ExecuteOnlyRole

GO
