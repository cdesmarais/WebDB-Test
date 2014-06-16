if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ScheduleShifts_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ScheduleShifts_Add]
GO




CREATE PROCEDURE dbo.Admin_ScheduleShifts_Add
 (
  @Schedule_ID int,
  @Shift_ID int,
  @Shift_Template_ID int,
  @Restaurant_ID int
 )
As
SET NOCOUNT ON
INSERT INTO ScheduleShifts
 (
  scheduleID,
  ShiftID,
  ShiftTemplateID,
  RID
 )
VALUES
 (
  @Schedule_ID,
  @Shift_ID,
  @Shift_Template_ID,
  @Restaurant_ID
 )
GO

GRANT EXECUTE ON [Admin_ScheduleShifts_Add] TO ExecuteOnlyRole

GO
