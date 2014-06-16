if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promo_GetPromoResults]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promo_GetPromoResults]
GO

CREATE PROCEDURE dbo.Admin_Promo_GetPromoResults

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select distinct 
			ExtranetLogin.userid as user_ID
			,count(Reservation.ResID) as reservations
			,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers
			,r.RID as restaurant_ID
			,r.RName as Name
			,n.metroareaid as Metro_Area_ID
			,ma.MetroAreaName as MetroName

from		DaySchedule
inner join	Incentive
on			DaySchedule.DSchID = Incentive.IncentiveDay
inner join	RestaurantVW r
on			Incentive.RID = r.RID
inner join	ExtranetLogin
on			r.RID = ExtranetLogin.RID
inner join	Neighborhood n
on			n.neighborhoodid = r.neighborhoodid
inner join	MetroAreaAVW ma
on			ma.metroareaid = ma.metroareaid
and			ma.LanguageID = r.LanguageID
left  join  Reservation
on			Incentive.RID = Reservation.RID 
and			RStateID not in (3,4,8,9,10) 
and			ResPoints = 1000 
and			DateMade > '3/31/2003' 
and			DATEPART(dw,ShiftDate) = Incentive.IncentiveDay 
and			Incentive.incentiveid = Reservation.incentiveid

where		n.metroareaid <> 1 
and			DSchID in (1,2,3,4,5,6,7) 

and			Startdate >= '3/29/2003'
and			Incentive.LastMinutePopThresholdTime IS NULL

group by	r.RID
			,r.RName
			,ExtranetLogin.userid
			,n.metroareaid
			,ma.MetroAreaName
			order by	ma.MetroAreaName
			,r.RName

GO

GRANT EXECUTE ON [Admin_Promo_GetPromoResults] TO ExecuteOnlyRole

GO
