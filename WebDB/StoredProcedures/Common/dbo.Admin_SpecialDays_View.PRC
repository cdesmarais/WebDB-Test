if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SpecialDays_View]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SpecialDays_View]
GO




CREATE PROCEDURE dbo.Admin_SpecialDays_View

@Restaurant_ID int

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



select assignmentdate as assignment_date,coalesce(DaySchedule.DSchName,'Special Shift') as ShiftName,SpcSchAssign.scheduleID as schedule_ID 
from SpcSchAssign 
inner join DaySchedule on SpcSchAssign.scheduleID = DaySchedule.DSchID
--inner join ScheduleShifts on SpcSchAssign.scheduleID = ScheduleShifts.scheduleID
where SpcSchAssign.RID =  @Restaurant_ID and SpcSchAssign.scheduleID > 8

order by assignmentdate
GO

GRANT EXECUTE ON [Admin_SpecialDays_View] TO ExecuteOnlyRole

GO
