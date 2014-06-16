if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReservationCutoff_Edit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReservationCutoff_Edit]
GO

CREATE PROCEDURE dbo.Admin_ReservationCutoff_Edit

@RestaurantID int,
@ShiftID int,
@ShiftTemplateID int,
@ScheduleID nvarchar(255)


 AS

Begin Transaction
--delete all previous records in ScheduleShifts for this ShiftTemplateID
Delete from ScheduleShifts where ShiftTemplateID = @ShiftTemplateID

--Insert new into ScheduleShifts
Declare @tempScheduleID nvarchar(255),
       @variable nvarchar(255)
       set @tempScheduleID = @ScheduleID + ','
       While len(@tempScheduleID) > 1
	   begin
	       Set @variable = convert(int,left(@tempScheduleID,charindex(',',@tempScheduleID) -1))
	       /*gets everything to the left of a comma*/
	       Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (@variable,@ShiftID,@ShiftTemplateID,@RestaurantID)
                     --print 'just inserted'
	       If @@Error <> 0 
                         goto error
	       Set @tempScheduleID = right(@tempScheduleID,len(@tempScheduleID) - charindex(',',@tempScheduleID))   /*trims off the leftmost comma and everything preceeding it */
	   end

Commit Transaction
Return(0)

error:
Rollback Transaction
GO

GRANT EXECUTE ON [Admin_ReservationCutoff_Edit] TO ExecuteOnlyRole

GO
