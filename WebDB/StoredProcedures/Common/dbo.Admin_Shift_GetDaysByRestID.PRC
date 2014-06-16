

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Shift_GetDaysByRestID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Shift_GetDaysByRestID]
go

create procedure dbo.Admin_Shift_GetDaysByRestID 
(
@RestaurantID int
)
as
set nocount on
set transaction isolation level read uncommitted

select 
    scheduleID as Schedule_ID
    ,ScheduleShifts.ShiftTemplateID as Shift_Template_ID 
from 
    ScheduleShifts
inner join 
    ShiftTemplate 
on 
    ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
where 
    ShiftTemplate.RID = @RestaurantID 
    and ShiftTemplate.Active = 1
    and ShiftTemplate.CutoffActive = 1

order by ShiftTemplate.ShiftTemplateID
go

grant execute on [Admin_Shift_GetDaysByRestID] to ExecuteOnlyRole

go

