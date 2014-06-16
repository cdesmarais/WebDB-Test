if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Report_Referral_Reservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Report_Referral_Reservations]
GO

CREATE PROCEDURE dbo.Admin_Report_Referral_Reservations
(
@date datetime
)
 AS
 
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select Referrer.ReferrerName as Name,count(Reservation.ResID) as reservations,
		sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers,
		n.metroareaid as Metro_Area_ID,left(DateMade,11) as resodate_made,0 as totalreso
from		Reservation
inner join	RestaurantVW r
on			Reservation.RID = r.RID
inner join	NeighborhoodAVW n 
on			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
inner join MetroAreaAVW m
on			n.metroareaid = m.metroareaid
and			r.LanguageID = m.LanguageID
inner join ReferrerReservationVW 
on			Reservation.ResID = ReferrerReservationVW.ResID -- and ReferrerID in (330,331,332,333,334,335,360,361,362)
inner join Referrer 
on			ReferrerReservationVW.ReferrerID = Referrer.ReferrerID -- and ReferrerID in (330,331,332,333,334,335,360,361,362)
where		n.metroareaid <> 1
and			RStateID not in (3,4,8,9,10)
and			ResPoints = 1000 
and			cast(left(DateMade,11) as datetime) = @date
group by	m.MetroAreaName
			,Referrer.ReferrerName
			,n.metroareaid
			,left(DateMade,11)
union

Select 'Total for ' + m.MetroAreaName as Name
			,count(Reservation.ResID) as reservations
			,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers
			,n.metroareaid as Metro_Area_ID
			,left(DateMade,11) as resodate_made
			,1 as totalreso
from		Reservation
inner join	RestaurantVW r
on			Reservation.RID = r.RID
inner join	NeighborhoodAVW n 
on			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
inner join	MetroAreaAVW m 
on			n.metroareaid = m.metroareaid
and			r.LanguageID = m.LanguageID
where		n.metroareaid <> 1
and			RStateID not in (3,4,8,9,10)
and			ResPoints = 1000 
and			cast(left(DateMade,11) as datetime) = @date
group by	m.MetroAreaName
			,n.metroareaid
			,left(DateMade,11)

union
Select 'Grand Total for all Restaurants' as Name
			,count(Reservation.ResID) as reservations
			,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers
			,4 as Metro_Area_ID
			,'May 40 2003' as resodate_made
			,2 as totalreso
from		Reservation
inner join	RestaurantVW r
on			Reservation.RID = r.RID
inner join	NeighborhoodAVW n 
on			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
inner join	MetroAreaAVW m 
on			n.metroareaid = m.metroareaid
and			r.LanguageID = m.LanguageID
where		n.metroareaid <> 1
and			RStateID not in (3,4,8,9,10) 
and			ResPoints = 1000 and DateMade > '3/31/2003'

order by resodate_made,Metro_Area_ID,totalreso,Name
GO

GRANT EXECUTE ON [Admin_Report_Referral_Reservations] TO ExecuteOnlyRole

GO
