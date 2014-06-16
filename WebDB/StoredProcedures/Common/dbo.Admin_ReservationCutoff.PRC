if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReservationCutoff]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReservationCutoff]
GO

CREATE PROCEDURE dbo.Admin_ReservationCutoff

(@RestaurantID int,
 @ShiftID int,
 @CutoffTime nvarchar(255),
 @CloseTime nvarchar(255),
 @Enabled bit,
 @Name nvarchar(255) = default)

AS

--first,delete any existing cutoffs for this restaurant
Delete from ScheduleShifts where RID = @RestaurantID and ShiftID = @ShiftID
Delete from ShiftTemplate where RID = @RestaurantID and ShiftID = @ShiftID

--Next,insert a record for the Shift into ShiftTemplate
Insert into ShiftTemplate (RID,ShiftID,STName,OpenTime,CloseTime,ResCutOffTime,CutoffActive) values
(@RestaurantID,@ShiftID,@Name,@CutoffTime,@CloseTime,@CutoffTime,@Enabled)

--Get the identity field of the above insert
declare @ShiftTemplateID int
Select @ShiftTemplateID = scope_identity()

--Finally,insert 7 records (one for each day of the week) into ScheduleShifts,for this one ShiftTemplateID
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (1,@ShiftID,@ShiftTemplateID,@RestaurantID)
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (2,@ShiftID,@ShiftTemplateID,@RestaurantID)
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (3,@ShiftID,@ShiftTemplateID,@RestaurantID)
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (4,@ShiftID,@ShiftTemplateID,@RestaurantID)
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (5,@ShiftID,@ShiftTemplateID,@RestaurantID)
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (6,@ShiftID,@ShiftTemplateID,@RestaurantID)
Insert into ScheduleShifts (scheduleID,ShiftID,ShiftTemplateID,RID) values (7,@ShiftID,@ShiftTemplateID,@RestaurantID)

Select ShiftTemplateID = @ShiftTemplateID
GO

GRANT EXECUTE ON [Admin_ReservationCutoff] TO ExecuteOnlyRole

GO
