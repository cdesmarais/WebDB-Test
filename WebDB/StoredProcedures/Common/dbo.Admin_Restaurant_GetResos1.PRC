if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetResos1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetResos1]
GO

create procedure dbo.Admin_Restaurant_GetResos1
(
	@Restaurant_ID int
	,@StartDate datetime
	,@EndDate datetime
)
as
set NOCOUNT on
set transaction ISOLATION LEVEL read UNCOMMITTED

--This Proc will fetch reservation data depend on @StartDate,@EndDate 

--This forces to get floor value of @StartDate E.g. 2008-01-01 00:00:00.000
set @StartDate =convert(datetime, floor(convert(float, @StartDate)))

--This forces to get floor value of (@EndDate+1)
set @EndDate =dateadd(dd,1, convert(datetime, floor(convert(float, @EndDate)))) 

select
	Reservation.ResID as Reservation_ID
	,ShiftDate as Shift_Date,ResTime as Reservation_Time
	,sum(	case 
			when(Coalesce(seatedSize,0) < 1) then Partysize 
			else seatedSize 
		end
		) as Party_size
	,ResPoints as Points_for_Reservation
	,coalesce(incentiveid,0) as Incentive_ID
	,Reservation.ContactPhone as Contact_Phone
	,coalesce(UseDiningCheque,0) as useCheque
	,Customer.FName as First_Name
	,Customer.LName as Last_Name
	,Customer.SFName as First_Name_phonetic
	,Customer.SLName as Last_Name_Phonetic
	,NULL as Booker_Lname
	,NULL as Booker_Fname
	,NULL as Booker_Lname_phonetic
	,NULL as Booker_Fname_Phonetic
	,Reservation.CustID as CID
	,DateMade as Date_Made
	-- Convert DateMade from PST to JST
	,dbo.fTimeConvert (DateMade,4,27) as Date_Made_JST
	,reservationState.RStateName as resoState
	,referrer.referrerID as Referrer_ID
	,email
	,(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer
	,confNumber as Confirmation_Number
	,ReferrerRestaurantReservationVW.rid as restref
	,referrer.referrername as Ref_Name
	,Reservation.PartnerID
	,Partner.PartnerName
	,Partner.PartnerTypeID
	,( case 
	   when(Reservation.FirstTime = 0) then 'No'
	   when(Reservation.FirstTime = 1) then 'Yes'
	   else 'N/A'
	   end
	) as First_Time_Diner
from 
	Reservation 
	inner join reservationState on
	Reservation.RStateID = reservationState.RStateID

	inner join Customer on
	Reservation.CustID = Customer.CustID
	
	inner join Partner on
	Reservation.PartnerID = Partner.PartnerID
	
	left outer join ReferrerReservationVW on
	ReferrerReservationVW.ResID = reservation.ResID

	left outer join referrer on
	referrer.referrerid = ReferrerReservationVW.referrerid
	
	left outer join ReferrerRestaurantReservationVW on
	reservation.RID = ReferrerRestaurantReservationVW.RID
	and reservation.resid = ReferrerRestaurantReservationVW.resid
	
	left join	ReservationOffer reservOffer
	on			reservOffer.ResID = Reservation.ResID
	left join	ReservationOfferVW reservOfferVw
	on			reservOffer.OfferID = reservOfferVw.OfferID
	and			reservOfferVw.OfferClassID = 3

where 
	Reservation.RID = @Restaurant_ID and
	ShiftDate >= @StartDate and
	ShiftDate < @EndDate and
	Reservation.RStateID = 1
group by
	Reservation.ResID
	,ShiftDate
	,resTime
	,ResPoints
	,IncentiveID
	,Reservation.ContactPhone
	,RStateName
	,Customer.FName
	,Customer.LName
	,Customer.SFname
	,Customer.SLName
	,DateMade
	,email
	,reservOfferVw.OfferClassID
	,referrer.referrerID
	,referrer.ReferrerName
	,UseDiningCheque
	,Reservation.CustID
	,confNumber
	,ReferrerRestaurantReservationVW.rid
	,Reservation.PartnerID
	,Partner.PartnerName
	,Partner.PartnerTypeID
	,Reservation.FirstTime
union all

Select
	 Reservation.ResID as Reservation_ID
	,ShiftDate as Shift_Date,ResTime as Reservation_Time
	,sum(	case 
			when(Coalesce(seatedSize,0) < 1) then Partysize 
			else seatedSize end
		)as Party_size
	,ResPoints as Points_for_Reservation
	,coalesce(incentiveid,0) as Incentive_ID
	,Reservation.ContactPhone as Contact_Phone
	,coalesce(UseDiningCheque,0) as useCheque
	,CallerCustomer.FName as First_Name
	,CallerCustomer.LName as Last_Name
	,CallerCustomer.SFName as First_Name_phonetic
	,CallerCustomer.SLName as Last_Name_Phonetic
	,Caller.LName as Booker_Lname
	,Caller.FName as Booker_Fname
	,Caller.SLName as Booker_Lname_phonetic
	,Caller.SFName as Booker_Fname_Phonetic
	,Reservation.CallerID as CID
	,DateMade as Date_Made
	-- Convert DateMade from PST to JST
	,dbo.fTimeConvert (DateMade,4,27) as Date_Made_JST
	,reservationState.RStateName as resoState
	,referrer.referrerID as Referrer_ID
	,Caller.email
	,(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer
	, confNumber
	,ReferrerRestaurantReservationVW.rid as restref
	,referrer.referrername as Ref_Name
	,Reservation.PartnerID
	,Partner.PartnerName
	,Partner.PartnerTypeID
	,( case 
	   when(Reservation.FirstTime = 0) then 'No'
	   when(Reservation.FirstTime = 1) then 'Yes'
	   else 'N/A'
	   end
	) as First_Time_Diner
from 
	Reservation 
	inner join reservationState on
	Reservation.RStateID = reservationState.RStateID

	inner join CallerCustomer on
	Reservation.custID = CallerCustomer.custID

	inner join Caller on
	Reservation.CallerID = Caller.CallerID

	inner join Partner on
	Reservation.PartnerID = Partner.PartnerID

	left outer join ReferrerReservationVW on
	ReferrerReservationVW.ResID = reservation.ResID
	
	left outer join referrer on
	referrer.referrerid = ReferrerReservationVW.referrerid

	left outer join ReferrerRestaurantReservationVW on
	reservation.RID = ReferrerRestaurantReservationVW.RID and
	reservation.resid = ReferrerRestaurantReservationVW.resid
	
	left join	ReservationOffer reservOffer
	on			reservOffer.ResID = Reservation.ResID
	left join	ReservationOfferVW reservOfferVw
	on			reservOffer.OfferID = reservOfferVw.OfferID
	and			reservOfferVw.OfferClassID = 3

where 
	Reservation.RID = @Restaurant_ID and
	ShiftDate >= @StartDate and
	ShiftDate < @EndDate and
	Reservation.RStateID = 1
group by 
	Reservation.ResID
	,ShiftDate
	,resTime
	,ResPoints
	,IncentiveID
	,Reservation.ContactPhone
	,RStateName
	,Caller.FName
	,Caller.LName
	,Caller.sfname
	,Caller.slname
	,DateMade
	,Caller.email
	,reservOfferVw.OfferClassID
	,referrer.referrerID
	,referrer.ReferrerName
	,UseDiningCheque
	,Reservation.CallerID
	,CallerCustomer.FName
	,CallerCustomer.LName
	,CallerCustomer.SFName
	,CallerCustomer.SLname
	,confNumber
	,ReferrerRestaurantReservationVW.rid
	,Reservation.PartnerID
	,Partner.PartnerName
	,Partner.PartnerTypeID
	,Reservation.FirstTime
order by 
	ShiftDate
	,ResTime

GO



grant execute on [Admin_Restaurant_GetResos1] to ExecuteOnlyRole

GO

