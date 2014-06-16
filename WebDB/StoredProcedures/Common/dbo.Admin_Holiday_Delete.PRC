if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_Delete]
GO




CREATE PROCEDURE dbo.Admin_Holiday_Delete
 (
  @Date_ID int
 )
As
SET NOCOUNT ON
DELETE FROM HolidaySchedule
WHERE (DateID = @Date_ID)
GO

GRANT EXECUTE ON [Admin_Holiday_Delete] TO ExecuteOnlyRole

GO
