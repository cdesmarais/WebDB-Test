if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetPromoResults]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetPromoResults]
GO

CREATE PROCEDURE dbo.Promo_GetPromoResults

AS

Select 
			 distinct ExtranetLogin.userid as user_ID
			,count(Reservation.ResID) as reservations
			,Coalesce(sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End),0) as covers
			,r.RID as restaurant_ID
			,r.RName as Name
			,DATEPART(dw,ShiftDate) as dayofweek
			,n.metroareaid as Metro_Area_ID
			,Incentive.IncentiveDay as Day
from		DaySchedule
inner join	Incentive
on			DaySchedule.DSchID = Incentive.IncentiveDay
inner join	RestaurantVW r
on			Incentive.RID = r.RID
inner join	ExtranetLogin
on			r.RID = ExtranetLogin.RID
inner join	Neighborhood n
on			r.neighborhoodid = n.neighborhoodid
left join	Reservation
on			Incentive.RID = Reservation.RID 
and			RStateID not in (3,4,8,9,10) 
and			ResPoints = 1000 
and			DateMade > '3/31/2003' 
and			DATEPART(dw,ShiftDate) = Incentive.IncentiveDay 
and			Incentive.incentiveid = Reservation.incentiveid
and			Incentive.LastMinutePopThresholdTime IS NULL
where n.metroareaid <> 1 
and	DSchID in (1,2,3,4,5,6,7) 
--and	incentive.active = 0
and	Startdate >= '3/29/2003'

group by	r.RID
,r.RName
,DATEPART(dw,ShiftDate)
,ExtranetLogin.userid
,n.metroareaid
,Incentive.IncentiveDay
order by	r.RID
,Incentive.IncentiveDay
GO

GRANT EXECUTE ON [Promo_GetPromoResults] TO ExecuteOnlyRole

GO
