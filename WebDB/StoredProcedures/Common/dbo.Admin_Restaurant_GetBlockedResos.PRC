
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetBlockedResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetBlockedResos]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetBlockedResos
(
  @Restaurant_ID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		Reservation.ResID as Reservation_ID
			,ShiftDate as Shift_Date,
			ResTime as Reservation_Time,
			sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Party_size, 
			ResPoints as Points_for_Reservation,Coalesce(incentiveid,0) as Incentive_ID,
			Reservation.ContactPhone as Contact_Phone,
			Coalesce(UseDiningCheque,0) as useCheque,
			Customer.FName as First_Name,
			Customer.LName as Last_Name,
			NULL as Booker_Lname,
			NULL as Booker_Fname,
			Reservation.CustID as CID,
			DateMade as Date_Made, 
			reservationState.RStateName as resoState, 
			referrerID as Referrer_ID, 
			email, 
			confNumber, 
			ReferrerRestaurantReservationVW.rid as restref
from Reservation 
inner join	reservationState 
on			Reservation.RStateID = reservationState.RStateID
inner join	Customer 
on			Reservation.CustID = Customer.CustID
inner join	BlockedDay bd on Reservation.RID = bd.RID 
and			bd.BlockedDate = ShiftDate
left outer join ReferrerReservationVW 
on			ReferrerReservationVW.ResID = reservation.ResID
left outer join ReferrerRestaurantReservationVW 
on			reservation.RID = ReferrerRestaurantReservationVW.RID
and			reservation.resid = ReferrerRestaurantReservationVW.resid
where		Reservation.RID = @Restaurant_ID 
and			ShiftDate > getdate()-1 
and			Reservation.RStateID = 1
group by	Reservation.ResID,ShiftDate, resTime, 
			ResPoints,
			IncentiveID,
			Reservation.ContactPhone, 
			RStateName,
			Customer.FName, 
			Customer.LName, 
			DateMade, 
			email, 
			referrerID, 
			UseDiningCheque, 
			Reservation.CustID, 
			confNumber, 
			ReferrerRestaurantReservationVW.rid

union all

Select		Reservation.ResID as Reservation_ID,
			ShiftDate as Shift_Date,
			ResTime as Reservation_Time,
			sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Party_size, 
			ResPoints as Points_for_Reservation,Coalesce(incentiveid,0) as Incentive_ID,
			Reservation.ContactPhone as Contact_Phone,
			Coalesce(UseDiningCheque,0) as useCheque,
			CallerCustomer.FName as First_Name,
			CallerCustomer.LName as Last_Name,
			Caller.LName as Booker_Lname,
			Caller.FName as Booker_Fname,
			Reservation.CallerID as CID,
			DateMade as Date_Made, 
			reservationState.RStateName as resoState, 
			referrerID as Referrer_ID, 
			Caller.email, 
			confNumber, 
			ReferrerRestaurantReservationVW.rid as restref
from	Reservation 
inner join	reservationState 
on			Reservation.RStateID = reservationState.RStateID
inner join	CallerCustomer 
on			Reservation.CallerID = CallerCustomer.CallerID 
and			Reservation.CustID = CallerCustomer.CustID
inner join	Caller 
on			Reservation.CallerID = Caller.CallerID
inner join	BlockedDay bd 
on			Reservation.RID = bd.RID 
and			bd.BlockedDate = ShiftDate
left outer join ReferrerReservationVW 
on			ReferrerReservationVW.ResID = reservation.ResID
left outer join ReferrerRestaurantReservationVW 
on			reservation.RID = ReferrerRestaurantReservationVW.RID
and			reservation.resid = ReferrerRestaurantReservationVW.resid
where		Reservation.RID = @Restaurant_ID 
and			ShiftDate > getdate()-1 
and			Reservation.RStateID = 1
group by	Reservation.ResID,
			ShiftDate, 
			resTime, 
			ResPoints,
			IncentiveID,
			Reservation.ContactPhone, 
			RStateName,
			Caller.FName, 
			Caller.LName, 
			referrerID,
			DateMade, 
			Caller.email, 
			referrerID, 
			UseDiningCheque, 
			Reservation.CallerID,
			CallerCustomer.FName, 
			CallerCustomer.LName, 
			confNumber, 
			ReferrerRestaurantReservationVW.rid
order by	ShiftDate,
			ResTime

GO

GRANT EXECUTE ON [Admin_Restaurant_GetBlockedResos] TO ExecuteOnlyRole

GO
