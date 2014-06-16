if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SpecialDays_CheckOverlap]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SpecialDays_CheckOverlap]
GO




CREATE PROCEDURE dbo.Admin_SpecialDays_CheckOverlap

@AssignmentDate datetime,
@RestaurantID int,
@ScheduleID int = 0

As
if @ScheduleID <> 0
BEGIN
select assignmentdate as assignment_date from SpcSchAssign where  RID = @RestaurantID
and cast(convert(nvarchar,assignmentdate,110) as datetime) = cast(convert(nvarchar,@AssignmentDate,110) as datetime) and scheduleID <> @ScheduleID


END

else
BEGIN
select assignmentdate as assignment_date from SpcSchAssign where  RID = @RestaurantID
and cast(convert(nvarchar,assignmentdate,110) as datetime) = cast(convert(nvarchar,@AssignmentDate,110) as datetime)

END
GO

GRANT EXECUTE ON [Admin_SpecialDays_CheckOverlap] TO ExecuteOnlyRole

GO
