if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetResosMadeFrom]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetResosMadeFrom]
GO


CREATE PROCEDURE dbo.Admin_Restaurant_GetResosMadeFrom
(
  @Restaurant_ID int,
  @Month datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Declare @EndDate datetime
Set @EndDate = Dateadd(dd,31,@Month)

Select Reservation.ResID as Reservation_ID,
ShiftDate as Shift_Date, 
ResTime as Reservation_Time, 
sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Party_size, 
ResPoints as Points_for_Reservation,
Coalesce(IncentiveID,0) as Incentive_ID,
ContactPhone as Contact_Phone, 
'' as Notes, 
Coalesce(UseDiningCheque,0) as useCheque,
Customer.FName as First_Name, 
Customer.LName as Last_Name, 
Customer.SFName as First_Name_phonetic, 
Customer.SLName as Last_Name_phonetic, 
Null as Booker_Lname, 
Null as Booker_Fname,
Null as Booker_Lname_phonetic, 
Null as Booker_Fname_phonetic,
Reservation.custID as CID, 
DateMade as Date_Made, 
email, 
referrer.referrerID as referrer_ID, 
reservationState.RStateName as resoState, 
ConfNumber as Confirmation_Number, ReferrerRestaurantReservationVW.rid as restref,referrer.referrername AS Ref_Name
from Reservation 
inner join reservationState on Reservation.RStateID = reservationState.RStateID
inner join Customer on Reservation.custID = Customer.custID
left outer join ReferrerReservationVW on ReferrerReservationVW.ResID = reservation.ResID
LEFT OUTER JOIN referrer ON referrer.referrerid = ReferrerReservationVW.referrerid
left outer join ReferrerRestaurantReservationVW on reservation.RID = ReferrerRestaurantReservationVW.RID
and reservation.resid = ReferrerRestaurantReservationVW.resid
where Reservation.RID = @Restaurant_ID and DateMade > @Month and DateMade < @EndDate
group by Reservation.ResID,ShiftDate, ResTime, referrer.ReferrerName, 
ResPoints,IncentiveID,
ContactPhone,RStateName,
FName, LName, SFName, SLName,
DateMade, email, referrer.referrerID, UseDiningCheque, Reservation.custID, ConfNumber, ReferrerRestaurantReservationVW.rid


union

Select Reservation.ResID as Reservation_ID,
ShiftDate as Shift_Date, 
ResTime as Reservation_Time, 
sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Party_size, 
ResPoints as Points_for_Reservation,
Coalesce(IncentiveID,0) as Incentive_ID,
Reservation.ContactPhone as Contact_Phone, 
'' as Notes, 
Coalesce(UseDiningCheque,0) as useCheque,
CallerCustomer.FName as First_Name, 
CallerCustomer.LName as Last_Name, 
CallerCustomer.SFName as First_Name_phonetic, 
CallerCustomer.SLName as Last_Name_phonetic, 
Caller.LName as Booker_Lname, 
Caller.FName as Booker_Fname,
Caller.SLName as Booker_Lname_phonetic, 
Caller.SFName as Booker_Fname_phonetic,
Reservation.custID as CID, 
DateMade as Date_Made, 
Caller.email, 
referrer.referrerID as referrer_ID, 
reservationState.RStateName as resoState, 
ConfNumber as Confirmation_Number, ReferrerRestaurantReservationVW.rid as restref,referrer.referrername AS Ref_Name
from Reservation 
inner join reservationState on Reservation.RStateID = reservationState.RStateID
inner join CallerCustomer on Reservation.custID = CallerCustomer.custID
inner join Caller on Reservation.CallerID = caller.CallerID
left outer join ReferrerReservationVW on ReferrerReservationVW.ResID = reservation.ResID
LEFT OUTER JOIN referrer ON referrer.referrerid = ReferrerReservationVW.referrerid
left outer join ReferrerRestaurantReservationVW on reservation.RID = ReferrerRestaurantReservationVW.RID
and reservation.resid = ReferrerRestaurantReservationVW.resid
where Reservation.RID = @Restaurant_ID and DateMade > @Month and DateMade < @EndDate
group by Reservation.ResID,ShiftDate, ResTime, 
ResPoints,IncentiveID,
Reservation.ContactPhone,RStateName,
CallerCustomer.FName, CallerCustomer.LName, 
CallerCustomer.SFName, CallerCustomer.SLName, referrer.ReferrerName,
Caller.LName, Caller.FName,
Caller.SLName, Caller.SFName,
DateMade, Caller.email, referrer.referrerID, UseDiningCheque, Reservation.custID, ConfNumber, ReferrerRestaurantReservationVW.rid
order by DateMade



GO

GRANT EXECUTE ON [Admin_Restaurant_GetResosMadeFrom] TO ExecuteOnlyRole

GO
