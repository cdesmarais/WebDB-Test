if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReservationCutoff_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReservationCutoff_Add]
GO




CREATE PROCEDURE dbo.Admin_ReservationCutoff_Add

 @RestaurantID int,
 @ShiftID int,
 @CutoffTime datetime,
 @CloseTime datetime,
 @Enabled bit,
 @Name nvarchar(255) = 'default',
 @ScheduleID nvarchar(255)


AS

--set the opentime/closetime
declare @OpenTime datetime
if @ShiftID = 1
	Begin 
		set @OpenTime = '12:00 AM'
		set @CloseTime = '3:59 PM'
	End
if @ShiftID = 2
	Begin
		set @OpenTime = '4:00 PM'
		set @CloseTime = '11:59 PM'
	End
	
Begin Transaction
   --First,insert a record for the Shift into ShiftTemplate
   Insert into ShiftTemplate (RID,ShiftID,STName,OpenTime,CloseTime,ResCutOffTime,CutoffActive) values
   (@RestaurantID,@ShiftID,@Name,@Opentime,@CloseTime,@CutoffTime,@Enabled)

   --Get the identity field of the above insert
   declare @ShiftTemplateID int
   Select @ShiftTemplateID = scope_identity()

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

GRANT EXECUTE ON [Admin_ReservationCutoff_Add] TO ExecuteOnlyRole

GO
