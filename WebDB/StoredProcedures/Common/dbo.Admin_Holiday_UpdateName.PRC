if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_UpdateName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_UpdateName]
GO




CREATE PROCEDURE dbo.Admin_Holiday_UpdateName
 (
  @HolidayID int,
  @Name nvarchar(200)
 )
As
SET NOCOUNT ON

UPDATE [HolidaysVW]
SET HolidayName  = @Name
WHERE HolidayID=  @HolidayID


GO


GRANT EXECUTE ON [Admin_Holiday_UpdateName] TO ExecuteOnlyRole

GO
