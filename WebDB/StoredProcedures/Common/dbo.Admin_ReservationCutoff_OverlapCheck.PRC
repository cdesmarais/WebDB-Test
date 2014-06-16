

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReservationCutoff_OverlapCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReservationCutoff_OverlapCheck]
go

create procedure dbo.Admin_ReservationCutoff_OverlapCheck
(
    @RestaurantID nvarchar(255)
    ,@ShiftID nvarchar(255)
    ,@ScheduleID nvarchar(255) = '0'
    ,@ShiftTemplateID nvarchar(255)
)
as

set nocount on
set transaction isolation level read uncommitted

begin

    select 	
        ScheduleShifts.ShiftTemplateID 
    from 	
        ScheduleShifts 
    inner join 
        ShiftTemplate 
    on 	
        ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID 
    where 	
        ScheduleShifts.RID = @RestaurantID
and 	ScheduleShifts.ShiftID =  @ShiftID 
        and ScheduleShifts.scheduleID 
                in (
                        select 
                            id 
                        from 
                            fIDStrToTab(@ScheduleID, ',')
                    ) 
and 	ShiftTemplate.ShiftTemplateID <> @ShiftTemplateID 
and 	ShiftTemplate.Active=1
        and ShiftTemplate.CutoffActive = 1

end

go

grant execute on [Admin_ReservationCutoff_OverlapCheck] to ExecuteOnlyRole

go

