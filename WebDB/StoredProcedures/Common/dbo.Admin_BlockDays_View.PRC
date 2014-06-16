if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_BlockDays_View]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_BlockDays_View]
GO




CREATE PROCEDURE dbo.Admin_BlockDays_View

@Restaurant_ID int

As
SET NOCOUNT ON


select assignmentdate,'' as ShiftName,'' as ShiftID,scheduleID from SpcSchAssign where RID =  @Restaurant_ID and scheduleID =8

Union

select assignmentdate,Shift.ShiftName as ShiftName,Shift.ShiftID as ShiftID,'0' as scheduleID 
from SpcBlockedShift inner join Shift on SpcBlockedShift.ShiftID = Shift.ShiftID
where RID = @Restaurant_ID 

Union


select assignmentdate,DaySchedule.DSchName as ShiftName,ScheduleShifts.ShiftID as ShiftID,SpcSchAssign.scheduleID 
from SpcSchAssign 
inner join DaySchedule on SpcSchAssign.scheduleID = DaySchedule.DSchID
inner join ScheduleShifts on SpcSchAssign.scheduleID = ScheduleShifts.scheduleID
where SpcSchAssign.RID =  @Restaurant_ID and SpcSchAssign.scheduleID > 8


order by assignmentdate

GO

GRANT EXECUTE ON [Admin_BlockDays_View] TO ExecuteOnlyRole

GO
