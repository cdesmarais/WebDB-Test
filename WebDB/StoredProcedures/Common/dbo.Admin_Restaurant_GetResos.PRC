if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetResos]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetResos
(
  @Restaurant_ID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select Reservation.ResID as Reservation_ID,ShiftDate as Shift_Date,ResTime as Reservation_Time,
sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Party_size, 
ResPoints as Points_for_Reservation,Coalesce(incentiveid,0) as Incentive_ID,Reservation.ContactPhone as Contact_Phone,
Coalesce(UseDiningCheque,0) as useCheque,
Customer.FName as First_Name,
Customer.LName as Last_Name,
Customer.SFName as First_Name_phonetic,
Customer.SLName as Last_Name_Phonetic, 
NULL as Booker_Lname, 
NULL as Booker_Fname,
NULL as Booker_Lname_phonetic, 
NULL as Booker_Fname_Phonetic,
Reservation.CustID as CID,DateMade as Date_Made, 
reservationState.RStateName as resoState, referrer.referrerID as Referrer_ID, email, confNumber as Confirmation_Number, ReferrerRestaurantReservationVW.rid as restref
,referrer.referrername AS Ref_Name
from Reservation 
inner join reservationState on Reservation.RStateID = reservationState.RStateID
inner join Customer on Reservation.CustID = Customer.CustID
left outer join ReferrerReservationVW on ReferrerReservationVW.ResID = reservation.ResID
LEFT OUTER JOIN referrer ON referrer.referrerid = ReferrerReservationVW.referrerid
left outer join ReferrerRestaurantReservationVW on reservation.RID = ReferrerRestaurantReservationVW.RID
and reservation.resid = ReferrerRestaurantReservationVW.resid
where Reservation.RID = @Restaurant_ID and ShiftDate > getdate()-1 and Reservation.RStateID = 1
group by Reservation.ResID,ShiftDate, resTime,
ResPoints,IncentiveID,
Reservation.ContactPhone, RStateName,
Customer.FName, Customer.LName, Customer.SFname, Customer.SLName,
DateMade, email, referrer.referrerID, referrer.ReferrerName, UseDiningCheque, Reservation.CustID, confNumber, ReferrerRestaurantReservationVW.rid

union

Select Reservation.ResID as Reservation_ID,ShiftDate as Shift_Date,ResTime as Reservation_Time,
sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Party_size, 
ResPoints as Points_for_Reservation,Coalesce(incentiveid,0) as Incentive_ID,Reservation.ContactPhone as Contact_Phone,
Coalesce(UseDiningCheque,0) as useCheque,
CallerCustomer.FName as First_Name,
CallerCustomer.LName as Last_Name,
CallerCustomer.SFName as First_Name_phonetic,
CallerCustomer.SLName as Last_Name_Phonetic, 
Caller.LName as Booker_Lname,
Caller.FName as Booker_Fname,
Caller.SLName as Booker_Lname_phonetic, 
Caller.SFName as Booker_Fname_Phonetic,
Reservation.CallerID as CID,DateMade as Date_Made, 
reservationState.RStateName as resoState, referrer.referrerID as Referrer_ID, Caller.email, confNumber as Confirmation_Number, ReferrerRestaurantReservationVW.rid as restref
,referrer.referrername AS Ref_Name
from Reservation 
inner join reservationState on Reservation.RStateID = reservationState.RStateID
inner join CallerCustomer on Reservation.custID = CallerCustomer.custID
inner join Caller on Reservation.CallerID = Caller.CallerID
left outer join ReferrerReservationVW on ReferrerReservationVW.ResID = reservation.ResID
LEFT OUTER JOIN referrer ON referrer.referrerid = ReferrerReservationVW.referrerid
left outer join ReferrerRestaurantReservationVW on reservation.RID = ReferrerRestaurantReservationVW.RID
and reservation.resid = ReferrerRestaurantReservationVW.resid
where Reservation.RID = @Restaurant_ID and ShiftDate > getdate()-1 and Reservation.RStateID = 1
group by Reservation.ResID,ShiftDate, resTime, 
ResPoints,IncentiveID,
Reservation.ContactPhone, RStateName,
Caller.FName, Caller.LName, Caller.sfname, Caller.slname, 
DateMade, Caller.email, referrer.referrerID,referrer.ReferrerName, UseDiningCheque, Reservation.CallerID,
CallerCustomer.FName, CallerCustomer.LName, CallerCustomer.SFName, CallerCustomer.SLname, confNumber, ReferrerRestaurantReservationVW.rid
order by ShiftDate,ResTime
GO



GRANT EXECUTE ON [Admin_Restaurant_GetResos] TO ExecuteOnlyRole

GO
