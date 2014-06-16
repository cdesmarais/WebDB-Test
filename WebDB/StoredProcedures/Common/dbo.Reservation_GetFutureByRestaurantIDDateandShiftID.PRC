if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetFutureByRestaurantIDDateandShiftID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetFutureByRestaurantIDDateandShiftID]
GO

CREATE Procedure dbo.Reservation_GetFutureByRestaurantIDDateandShiftID
@RestaurantID int,
@Date datetime,
@ShiftID int
 AS


 SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @closetime datetime--,@Date datetime
Select @closetime = CloseTime from ShiftTemplate where RID = @restaurantID and ShiftID = @shiftID
set @closetime = (cast (convert(nvarchar,@closetime,108) as datetime))
Select @Date = (cast(convert(nvarchar,getDate(),110) as datetime))

(
Select Reservation.ShiftDate as Shift_Date,Right( convert(nvarchar, Reservation.ResTime,100),7) as reservation_time,Reservation.Notes,Reservation.PartySize as Party_Size, Reservation.ResID as reservation_ID,Reservation.FirstTime as first_time,Reservation.business,
(cast(convert(nvarchar,Reservation.DateMade, 110)as datetime)) as date_made,Reservation.ContactPhone as contact_phone,Customer.LName +',' +  Customer.FName  as name
from Reservation 
inner join Customer on Reservation.CustID = Customer.CustID 
where RID = @RestaurantID and RStateID = 1 and 
Reservation.CallerID is null and 
(ShiftDate + 2 + ResTime)  >  (@date + @closetime)
--order by Reservation.ShiftDate,Reservation.ResTime asc
)
union
(
Select Reservation.ShiftDate as Shift_Date,Right( convert(nvarchar, Reservation.ResTime,100),7) as reservation_time,Reservation.Notes,Reservation.PartySize as Party_Size, Reservation.ResID as reservation_ID,Reservation.FirstTime as first_time,Reservation.business,
(cast(convert(nvarchar,Reservation.DateMade, 110)as datetime)) as date_made,Reservation.ContactPhone as contact_phone,CallerCustomer.LName +',' +  CallerCustomer.FName  as name
from Reservation 
inner join CallerCustomer on Reservation.CustID = CallerCustomer.CustID 
where RID = @RestaurantID and RStateID = 1 and 
Reservation.CallerID is not null and
(ShiftDate + 2 + ResTime)  >  (@date + @closetime)
--order by Reservation.ShiftDate,Reservation.ResTime asc
)

order by Shift_Date,reservation_time asc
GO

GRANT EXECUTE ON [Reservation_GetFutureByRestaurantIDDateandShiftID] TO ExecuteOnlyRole

GO
