if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_NonPromoReservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_NonPromoReservations]
GO

CREATE PROCEDURE dbo.Admin_NonPromoReservations
  @Shift_Date datetime,
  @Promo_ID int
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		r.RName as name
			,r.RID as Restaurant_ID
			,FName as first_Name
			,LName as last_Name
			,Customer.CustID as CustID
			,Customer.email
			,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size
			,ShiftDate as shift_date
			,ResTime as Reservation_Time
			,DateMade as Date_Made
			,ma.MetroAreaName as MetroName
			,'No' as Admin 
from		Reservation res
left join	PromoRests 
on			res.RID = PromoRests.RID 
and			PromoID = @Promo_ID
inner join	RestaurantAVW r 
on			r.RID = res.RID
and			r.LanguageID = res.LanguageID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = res.LanguageID
inner join	MetroAreaLocal ma 
on			ma.metroareaid = n.metroareaid
and			ma.LanguageID = res.LanguageID
inner join	Customer 
on			res.CustID = Customer.CustID
where		ShiftDate = @Shift_Date 
and			RStateID = 1 
and			PromoRests.PromoID is null 
and			res.CallerID is null 
and			n.metroareaid <> 1

union all

Select 
			r.RName as name
			,r.RID as Restaurant_ID
			,CallerCustomer.FName as first_Name
			,CallerCustomer.LName as last_Name
			,CallerCustomer.CustID as CustID
			,coalesce(CallerCustomer.email
			,CallerCustomer.email
			,CallerPhone.Phone,'') as email
			,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size
			,ShiftDate as shift_date
			,ResTime as Reservation_Time
			,DateMade as Date_Made
			,ma.MetroAreaName as MetroName
			,(Case when(Caller.PartnerID = 5) Then 'Concierge' Else 'Admin' End) as Admin 
from		Reservation res
left join	PromoRests on res.RID = PromoRests.RID and PromoID = @Promo_ID
inner join	RestaurantAVW r 
on			r.RID = res.RID
and			r.LanguageID = res.LanguageID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = res.LanguageID
inner join	MetroAreaLocal ma 
on			ma.metroareaid = n.metroareaid
and			ma.LanguageID = res.LanguageID
inner join	CallerCustomer 
on			res.CustID = CallerCustomer.CustID
inner join	Caller 
on			res.CallerID = Caller.CallerID
inner join	CallerPhone 
on			Caller.CallerID = CallerPhone.CallerID
where		ShiftDate = @Shift_Date 
and			RStateID = 1 
and			PromoRests.PromoID is null 
and			res.CallerID is not null 
and			n.metroareaid <> 1

order by	ma.MetroAreaName
			,r.RName

GO

GRANT EXECUTE ON [Admin_NonPromoReservations] TO ExecuteOnlyRole

GO
