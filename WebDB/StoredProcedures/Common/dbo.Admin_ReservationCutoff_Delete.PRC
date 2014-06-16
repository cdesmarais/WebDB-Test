

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReservationCutoff_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReservationCutoff_Delete]
go

create procedure dbo.Admin_ReservationCutoff_Delete 
(
@ShiftTemplateID int
)
as
/*This procedure deletes the cutoff days and also the shift template*/
delete from 
    ScheduleShifts 
where 
    ShiftTemplateID = @ShiftTemplateID

delete from 
    ShiftTemplate
where 
    ShiftTemplateID = @ShiftTemplateID

go

grant execute on [Admin_ReservationCutoff_Delete] to ExecuteOnlyRole

go

