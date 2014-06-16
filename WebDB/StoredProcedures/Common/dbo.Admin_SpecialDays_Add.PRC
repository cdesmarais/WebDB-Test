if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SpecialDays_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SpecialDays_Add]
GO




CREATE PROCEDURE dbo.Admin_SpecialDays_Add
 (
  @Schedule_ID int,
  @RestaurantID int,
  @assignment_date datetime,
  @ShiftID int = 0
 )
As


SET NOCOUNT ON
if @ShiftID = 0
   BEGIN
      INSERT INTO SpcSchAssign (scheduleID,RID,assignmentdate)
      VALUES(@Schedule_ID,@RestaurantID,@assignment_date)
   End

else
   Begin
      Insert into SpcBlockedShift (ShiftID,RID,assignmentdate)
      values (@ShiftID,@RestaurantID,@assignment_date)
   End
GO

GRANT EXECUTE ON [Admin_SpecialDays_Add] TO ExecuteOnlyRole

GO
