if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetShiftCutoffTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetShiftCutoffTime]
GO

CREATE PROCEDURE dbo.Restaurant_GetShiftCutoffTime
(
@restaurant_id int,
@ResDateTime datetime
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

select ResCutOffTime as reservation_cutoff_time 
from ShiftTemplate
inner join ScheduleShifts 
on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
inner join Restaurant r 
on r.RID = ScheduleShifts.RID
where ScheduleShifts.scheduleID = datepart(dw,getDate()) -- day of week
and CutoffActive = 1
and ShiftTemplate.OpenTime < cast(CONVERT(nvarchar,@ResDateTime,108) as datetime)
and ShiftTemplate.CloseTime > cast(CONVERT(nvarchar,@ResDateTime,108) as datetime)
and ScheduleShifts.RID = @restaurant_id

GO

GRANT EXECUTE ON [Restaurant_GetShiftCutoffTime] TO ExecuteOnlyRole

GO
