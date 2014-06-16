
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCharmMetricReportTab1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCharmMetricReportTab1]
GO


CREATE PROCEDURE dbo.JobCharmMetricReportTab1

AS
SET NOCOUNT ON
set traNSACTION ISOLATION LEVEL READ UNCOMMITTED


select final.* from 
(select res.neighborhoodID,res.rName, res.RID, res.MinOnlineOptionID,
case when res.maxOnlineOptionID=31 then 'Any Size'
else cast(res.maxOnlineOptionID as varchar) End as MaxonlineSize , 
b.MaxAdvanceOption, 
case when res.maxLargePartyID=31 then 'Any Size'
else cast(res.maxLargePartyID as varchar) End as MaxLargePartySize , 
case when res.acceptLargeParty=1 then 'Yes'
else 'No' End as AcceptLargeParty
 , y.cutOff, x.cover, z.MetroAreaName, z.metroAreaID, res.RestStateID, rstate.rstate, getdate() as ReportDate
from restaurantVW res
inner join MaxAdvanceOption b 
on res.MaxAdvanceOptionID=b.MaxAdvanceOptionID
		left join (Select restaurant.rID, 'Yes' as cutOff
		from ScheduleShifts
		inner join shifttemplate 
		on ScheduleShifts.shifttemplateID = shifttemplate.shifttemplateID
		inner join shift 
		on ScheduleShifts.ShiftID = shift.ShiftID
		inner join DaySchedule 
		on ScheduleShifts.ScheduleID = DaySchedule.DSchID
		inner join restaurant 
		on ScheduleShifts.rID = restaurant.rID
		inner join neighborhood 
		on restaurant.neighborhoodID = neighborhood.neighborhoodID
		inner join MetroArea 
		on neighborhood.MetroAreaID = MetroArea.MetroAreaID
		where restStateID = 1 and ScheduleShifts.scheduleID in (1,2,3,4,5,6,7) and restaurant.Allotment = 0 and cutoffactive = 1
		group by restaurant.rID)y
on y.rID = res.RID
inner join (select me.metroAreaName, me.metroAreaID, ne.NeighborhoodID from neighborhoodVW ne 
inner join metroAreaAVW me on ne.metroAreaID = me.metroAreaID and ne.LanguageID = me.LanguageID) Z
on Z.neighborhoodID = res.neighborhoodID
inner join restaurantState rstate
on res.reststateID = rstate.reststateID
left join (select RID, sum(seatedSize)as cover from financeextract group by RID)x
on res.RID =x.RID where res.RestStateID not in (4,8,10,11,12,14,15) and 
z.MetroAreaID not in (1,67) )final
order by final.RID



GO


GRANT EXECUTE ON [JobCharmMetricReportTab1] TO ExecuteOnlyRole

GO
