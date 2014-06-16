if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_PendingBlockedResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_PendingBlockedResos]
GO

CREATE PROCEDURE dbo.Report_PendingBlockedResos

As

SET NOCOUNT ON
set transaction isolation level read uncommitted


Select rt.RName
		,rt.RID
		,rc.FName
		,rc.LName
		,rc.CustID as CustID
		,rc.Email
		,r.PartySize
		,r.ShiftDate
		,r.ResTime
		,r.DateMade
		,ma.MetroAreaName
		,'0' as Admin
		,pt.PhoneType
		,cp.Phone

from		Reservation r

inner join	RestaurantVW rt
on			r.RID = rt.RID
inner join	Neighborhood n
on			rt.NeighborhoodID = n.NeighborhoodID
inner join	Customer rc
on			r.CustID = rc.CustID
inner join	CustomerPhone cp
on			rc.CustID = cp.CustID 
and			cp.IsPrimary = 1
inner join	MetroAreaAVW ma
on			n.MetroAreaID = ma.MetroAreaID
and			r.LanguageID = ma.LanguageID
inner join	ConsumerTypes ct
on			rc.ConsumerType = ct.ConsumerTypeID
inner join	BlockedDay bd
on			r.RID = bd.RID 
inner join	PhoneType pt
on			pt.PhoneTypeID=cp.PhoneTypeID
and			bd.BlockedDate = r.ShiftDate
where		r.RStateID = 1

union


Select ma.MetroAreaName
			,rt.RID
			,c.FName
			,c.LName
			,c.CallerID as CustID
			,c.Email
			,PartySize
			,ShiftDate
			,ResTime
			,DateMade
			,ma.MetroAreaName
			,'1' as Admin
			,ct.ConsumerTypeTypeName
			,cp.Phone
from		Reservation r

inner join	RestaurantVW rt
on			r.RID = rt.RID
inner join	Neighborhood n
on			rt.NeighborhoodID = n.NeighborhoodID
inner join	Caller c
on			r.CallerID = c.CallerID
inner join	CallerPhone cp
on			c.CallerID = cp.CallerID 
and			cp.IsPrimary = 1
inner join	MetroAreaAVW ma
on			n.MetroAreaID = ma.MetroAreaID
and			r.LanguageID = ma.LanguageID
inner join	ConsumerTypes ct
on			c.ConsumerType = ct.ConsumerTypeID
inner join	BlockedDay bd
on			r.RID = bd.RID 
and			bd.BlockedDate = ShiftDate
where		RStateID = 1
order by rt.RName
GO


GRANT EXECUTE ON [Report_PendingBlockedResos] TO ExecuteOnlyRole

GO
