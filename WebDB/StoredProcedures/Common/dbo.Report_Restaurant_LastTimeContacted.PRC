if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_LastTimeContacted]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_LastTimeContacted]
GO

CREATE PROCEDURE dbo.Report_Restaurant_LastTimeContacted

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select rt.RID
		,rt.RName
		,ma.MetroAreaName
		,OTErb.ServerIP
		,OTErb.ServerPwd
		,LTC.LTC
From		ErbRestaurant OTErb
inner join	RestaurantVW rt 
on			OTErb.RID = rt.RID
inner join	Neighborhood n 
on			rt.NeighborhoodID = n.NeighborhoodID
inner join	MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			rt.LanguageId = ma.LanguageId
inner join	LastTimeContacted LTC 
on			LTC.RID = OTErb.RID
Where		datediff(n,LTC.LTC, getdate()) > 5
and			(rt.RestStateID = 1)
and			rt.Allotment = 0
and			ma.MetroAreaID <> 1
Order By	LTC.LTC

GO

GRANT EXECUTE ON [Report_Restaurant_LastTimeContacted] TO ExecuteOnlyRole

GO
