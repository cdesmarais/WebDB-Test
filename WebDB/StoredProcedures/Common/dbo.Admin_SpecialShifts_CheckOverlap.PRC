if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SpecialShifts_CheckOverlap]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SpecialShifts_CheckOverlap]
GO




CREATE PROCEDURE dbo.Admin_SpecialShifts_CheckOverlap

@AssignmentDate datetime,
@RestaurantID int,
@ShiftID int = -1

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if @ShiftID = -1
    BEGIN
      select assignmentdate as assignment_date from SpcBlockedShift where 
      RID = @RestaurantID
      and cast(convert(nvarchar,assignmentdate,110) as datetime) = cast(convert(nvarchar,@AssignmentDate,110) as datetime)
   END

ELSE

   BEGIN
      select assignmentdate as assignment_date from SpcBlockedShift where 
      RID = @RestaurantID
      and ShiftID = @ShiftID
      and cast(convert(nvarchar,assignmentdate,110) as datetime) = cast(convert(nvarchar,@AssignmentDate,110) as datetime)
   END
GO

GRANT EXECUTE ON [Admin_SpecialShifts_CheckOverlap] TO ExecuteOnlyRole

GO
