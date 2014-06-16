
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCharmMetricReportTab2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCharmMetricReportTab2]
GO


CREATE PROCEDURE dbo.JobCharmMetricReportTab2

AS
SET NOCOUNT ON
set traNSACTION ISOLATION LEVEL READ UNCOMMITTED

Select restaurant.rID, restaurant.rname, 'Yes' as cutOff,shiftname, DschName, rescutofftime,getdate() as ReportDate
from ScheduleShifts
inner join shifttemplate 
on ScheduleShifts.shifttemplateID = shifttemplate.shifttemplateID
inner join shift 
on ScheduleShifts.ShiftID = shift.ShiftID
inner join DaySchedule 
on ScheduleShifts.ScheduleID = DaySchedule.DSchID
inner join restaurantVW Restaurant
on ScheduleShifts.rID = restaurant.rID
inner join neighborhoodAVW neighborhood
on restaurant.neighborhoodID = neighborhood.neighborhoodID
and restaurant.languageID = neighborhood.languageID
inner join MetroAreaAVW MetroArea
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
and neighborhood.languageID = MetroArea.languageID
where restStateID = 1 and ScheduleShifts.scheduleID in (1,2,3,4,5,6,7) 
and restaurant.Allotment = 0 and cutoffactive = 1
order by restaurant.rID



GO


GRANT EXECUTE ON [JobCharmMetricReportTab2] TO ExecuteOnlyRole

GO
