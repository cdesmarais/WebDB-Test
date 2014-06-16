if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetByRestaurantIDDateandShiftID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetByRestaurantIDDateandShiftID]
GO

CREATE Procedure dbo.Reservation_GetByRestaurantIDDateandShiftID
@RestaurantID int,
@Date datetime,
@ShiftID int
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

(Select  Reservation.ShiftDate as Shift_Date,
Right( convert(nvarchar, Reservation.ResTime,100),7) as reservation_time,
Reservation.Notes,Reservation.PartySize as Party_Size,
Reservation.ResID as reservation_ID,Reservation.FirstTime as first_time,
Reservation.business,isnull(Reservation.UseDiningCheque,0) as Use_Dining_Cheque,
(cast(convert(nvarchar,Reservation.DateMade, 110) as datetime)) as date_made,
Reservation.ContactPhone as contact_phone,
Customer.LName + ',' +  Customer.FName as name
from Reservation  
inner join Customer on Reservation.CustID = Customer.CustID 
where RID = @RestaurantID 
and Reservation.CallerID is null
and ShiftDate = cast(convert(nvarchar,@Date,110) as datetime) 
and ShiftID = @ShiftID and RStateID = 1
--order by Reservation.ResTime asc
)

union

(Select Reservation.ShiftDate as Shift_Date,
Right( convert(nvarchar, Reservation.ResTime,100),7) as reservation_time,
Reservation.Notes as notes,Reservation.PartySize as Party_Size,
Reservation.ResID as reservation_ID,Reservation.FirstTime as first_time,
Reservation.business,isnull(Reservation.UseDiningCheque,0) as Use_Dining_Cheque, 
(cast(convert(nvarchar,Reservation.DateMade, 110) as datetime)) as date_made,
Reservation.ContactPhone as contact_phone,
CallerCustomer.LName + ',' +  CallerCustomer.FName as name
from Reservation  
inner join CallerCustomer on Reservation.CustID = CallerCustomer.CustID 
inner join Caller on CallerCustomer.CallerID = Caller.CallerID 
inner join Company on Caller.CompanyID = Company.CompanyID
where RID = @RestaurantID
and Reservation.CallerID is not null
and ShiftDate = cast(convert(nvarchar,@Date,110) as datetime) 
and ShiftID = @ShiftID and RStateID = 1
and isnull(Caller.CompanyID,0) = 0
--order by Reservation.ResTime asc
)

union

(Select Reservation.ShiftDate as Shift_Date,
Right( convert(nvarchar, Reservation.ResTime,100),7) as reservation_time,
Reservation.Notes + ' - Reservation made by ' + Caller.FName +' ' +  Caller.LName + ' at ' + Company.CompanyName as notes,
Reservation.PartySize as Party_Size,
Reservation.ResID as reservation_ID,Reservation.FirstTime as first_time,
Reservation.business,isnull(Reservation.UseDiningCheque,0) as Use_Dining_Cheque, 
(cast(convert(nvarchar,Reservation.DateMade, 110) as datetime)) as date_made,
Reservation.ContactPhone as contact_phone,
CallerCustomer.LName + ',' +  CallerCustomer.FName as name
from Reservation  
inner join CallerCustomer on Reservation.CustID = CallerCustomer.CustID 
inner join Caller on CallerCustomer.CallerID = Caller.CallerID 
inner join Company on Caller.CompanyID = Company.CompanyID
where RID = @RestaurantID
and Reservation.CallerID is not null
and ShiftDate = cast(convert(nvarchar,@Date,110) as datetime) 
and ShiftID = @ShiftID and RStateID = 1
and isnull(Caller.CompanyID,0) <> 0
--order by Reservation.ResTime asc
)


order by reservation_time asc
GO

GRANT EXECUTE ON [Reservation_GetByRestaurantIDDateandShiftID] TO ExecuteOnlyRole

GO
