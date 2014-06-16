if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SpecialDays_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SpecialDays_Update]
GO




CREATE PROCEDURE dbo.Admin_SpecialDays_Update
 (
  @Schedule_ID int,
  @RestaurantID int,
  @name nvarchar(50),
  @assignment_date datetime
 )
As


SET NOCOUNT ON

Update SpcSchAssign set assignmentdate = @assignment_date 
where scheduleID = @Schedule_ID and RID = @RestaurantID

Update DaySchedule set DSchName = @name where DSchID = @Schedule_ID
GO

GRANT EXECUTE ON [Admin_SpecialDays_Update] TO ExecuteOnlyRole

GO
