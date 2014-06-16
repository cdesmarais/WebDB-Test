if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetMonthsResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetMonthsResos]
GO


CREATE PROCEDURE dbo.Admin_Restaurant_GetMonthsResos
(
  @Restaurant_ID int,
  @Month datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--This forces the @month to always be the first of each month
set @month = DateAdd(d, -(day(@month)-1), dbo.fGetDatePart(@month))

Select			Reservation.ResID as Reservation_ID,
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
				-- Convert DateMade from PST to JST
				dbo.fTimeConvert (DateMade,4,27) as Date_Made_JST,
				email, 
				(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer,
				referrer.referrerid as referrer_ID, 
				reservationState.RStateName as resoState, 
				ConfNumber as Confirmation_Number, ReferrerRestaurantReservationVW.rid as restref,referrer.referrername AS Ref_Name,
				Reservation.PartnerID,
				Partner.PartnerName,
				Partner.PartnerTypeID,
				( case 
				  when(Reservation.FirstTime = 0) then 'No'
				  when(Reservation.FirstTime = 1) then 'Yes'
				  else 'N/A'
				  end
				) as First_Time_Diner

from			Reservation 
inner join		reservationState 
on				Reservation.RStateID = reservationState.RStateID
inner join		Customer 
on				Reservation.custID = Customer.custID

inner join		Partner 
on				Reservation.PartnerID = Partner.PartnerID


left outer join ReferrerReservationVW 
on				ReferrerReservationVW.ResID = reservation.ResID
LEFT OUTER JOIN referrer 
ON				referrer.referrerid = ReferrerReservationVW.referrerid
left outer join ReferrerRestaurantReservationVW on reservation.RID = ReferrerRestaurantReservationVW.RID
and				reservation.resid = ReferrerRestaurantReservationVW.resid

left join	ReservationOffer reservOffer
on			reservOffer.ResID = Reservation.ResID
left join	ReservationOfferVW reservOfferVw
on			reservOffer.OfferID = reservOfferVw.OfferID
and			reservOfferVw.OfferClassID = 3


where			Reservation.RID = @Restaurant_ID 
and				shiftDate >= @Month and shiftDate < DateAdd(m, 1, @Month)
group by		Reservation.ResID,ShiftDate, ResTime, referrer.ReferrerName,
				ResPoints,IncentiveID,
				ContactPhone,RStateName,
				FName, LName, SFName, SLname,
				DateMade, email, referrer.referrerid, UseDiningCheque, Reservation.custID, ConfNumber, ReferrerRestaurantReservationVW.rid,
				reservOfferVw.OfferClassID,
				Reservation.PartnerID,
				Partner.PartnerName,
				Partner.PartnerTypeID,
				Reservation.FirstTime

union all

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
				Reservation.CallerID as CID, 
				DateMade as Date_Made, 
				-- Convert DateMade from PST to JST
				dbo.fTimeConvert (DateMade,4,27) as Date_Made_JST,
				Caller.email, 
				(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer,
				referrer.referrerid as referrer_ID, 
				reservationState.RStateName as resoState, 
				ConfNumber as Confirmation_Number, ReferrerRestaurantReservationVW.rid as restref,referrer.referrername AS Ref_Name,
				Reservation.PartnerID,
				Partner.PartnerName,
				Partner.PartnerTypeID,
				( case 
				  when(Reservation.FirstTime = 0) then 'No'
				  when(Reservation.FirstTime = 1) then 'Yes'
				  else 'N/A'
				  end
				) as First_Time_Diner
				
from			Reservation 
inner join		reservationState 
on				Reservation.RStateID = reservationState.RStateID
inner join		CallerCustomer 
on				Reservation.custID = CallerCustomer.custID
inner join		Caller 
on				Reservation.CallerID = caller.CallerID

inner join		Partner 
on				Reservation.PartnerID = Partner.PartnerID

left outer join ReferrerReservationVW 
on				ReferrerReservationVW.ResID = reservation.ResID
LEFT OUTER JOIN referrer 
ON				referrer.referrerid = ReferrerReservationVW.referrerid
left outer join ReferrerRestaurantReservationVW 
on				reservation.RID = ReferrerRestaurantReservationVW.RID
and				reservation.resid = ReferrerRestaurantReservationVW.resid

left join	ReservationOffer reservOffer
on			reservOffer.ResID = Reservation.ResID
left join	ReservationOfferVW reservOfferVw
on			reservOffer.OfferID = reservOfferVw.OfferID
and			reservOfferVw.OfferClassID = 3


where			Reservation.RID = @Restaurant_ID 
and				shiftDate >= @Month and shiftDate < DateAdd(m, 1, @Month)
group by		Reservation.ResID,ShiftDate, ResTime, referrer.ReferrerName,
				ResPoints,IncentiveID,
				Reservation.ContactPhone,RStateName,
				CallerCustomer.FName, CallerCustomer.LName, 
				CallerCustomer.SFName, CallerCustomer.SLname,
				Caller.LName, Caller.FName,
				Caller.SLname, Caller.SFname,
				Reservation.PartnerID,
				Partner.PartnerName,
				Partner.PartnerTypeID,
				DateMade, Caller.email, referrer.referrerid, UseDiningCheque, Reservation.CallerID, ConfNumber, ReferrerRestaurantReservationVW.rid,
				reservOfferVw.OfferClassID,
				Reservation.FirstTime
order by		ShiftDate, ResTime


GO

GRANT EXECUTE ON [Admin_Restaurant_GetMonthsResos] TO ExecuteOnlyRole

GO
