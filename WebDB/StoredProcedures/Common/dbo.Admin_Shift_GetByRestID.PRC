

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Shift_GetByRestID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Shift_GetByRestID]
go

create procedure dbo.Admin_Shift_GetByRestID
(
@RestaurantID int
)
as

set nocount on
set transaction isolation level read uncommitted

select 
			r.RName as RestName
			,r.RID as Restaurant_ID
			,ShiftTemplateID as shift_template_ID
			,ShiftTemplate.STName as ShiftName
			,ResCutOffTime as Time
			,ShiftTemplate.CloseTime as Close_Time
			,ShiftID as Shift_ID
    from		 
        ShiftTemplate 
        inner join	
            RestaurantVW r
        on			
            r.RID = ShiftTemplate.RID
    where		
        ShiftTemplate.RID= @RestaurantID 
and			Active = 1
        and CutoffActive = 1
order by	ShiftTemplateID

go

grant execute on [Admin_Shift_GetByRestID] to ExecuteOnlyRole

go

