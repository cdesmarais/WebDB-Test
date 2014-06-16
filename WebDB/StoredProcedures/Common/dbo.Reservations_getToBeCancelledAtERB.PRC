if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservations_getToBeCancelledAtERB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservations_getToBeCancelledAtERB]
GO




CREATE PROCEDURE dbo.Reservations_getToBeCancelledAtERB
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted



delete from ReservationsToBeCancelled 
where ResID in	(select rtc.resid 
			 from reservationstobecancelled rtc 
			 inner join reservation r 
			 on rtc.resid = r.resid 
			 where r.shiftdate + 2 + r.restime < getdate()
			 )



select FName AS FirstName
,LName AS LastName
,ERBRestaurant.ServerIP AS NetAddress
,ERBRestaurant.ServerPwd AS Password
,Reservation.ConfNumber AS Confirmation
,Reservation.ResID as ReservationID
,ReservationsToBeCancelled.CallCenterNotified as CallCenterNotified
,Case when convert(nvarchar,getdate(),110) = convert(nvarchar,Reservation.ShiftDate,110) 
 then 1 else 0 end as IsResoForToday,Reservation.RID as RID

from customer 
inner join Reservation 
on customer.custID = Reservation.custID 
inner join ReservationsToBeCancelled 
on ReservationsToBeCancelled.ResID = Reservation.ResID  
INNER JOIN ERBRestaurant 
ON Reservation.RID = ERBRestaurant.RID 
where (reservation.callerid is null 
or reservation.callerid = 0)


union

select FName AS FirstName
,LName AS LastName
,ERBRestaurant.ServerIP AS NetAddress
,ERBRestaurant.ServerPwd AS Password
,Reservation.ConfNumber AS Confirmation
,Reservation.ResID as ReservationID
,ReservationsToBeCancelled.CallCenterNotified as CallCenterNotified
,Case when convert(nvarchar,getdate(),110) = convert(nvarchar,Reservation.ShiftDate,110) 
 then 1 else 0 end as IsResoForToday,Reservation.RID as RID

from callercustomer 
inner join Reservation 
on callercustomer.CustID = Reservation.CustID 
inner join ReservationsToBeCancelled 
on ReservationsToBeCancelled.ResID = Reservation.ResID  
INNER JOIN ERBRestaurant 
ON Reservation.RID = ERBRestaurant.RID 
where reservation.callerid is not null 
and  reservation.callerid > 0

GO

GRANT EXECUTE ON [Reservations_getToBeCancelledAtERB] TO ExecuteOnlyRole

GO
