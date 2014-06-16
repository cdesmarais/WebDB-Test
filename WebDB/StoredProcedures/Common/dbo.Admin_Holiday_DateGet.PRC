if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_DateGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_DateGet]
GO




CREATE PROCEDURE dbo.Admin_Holiday_DateGet
(
  @Date_ID int = 0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select HolidayDate as Holiday_Date, CountryID, SuppressDIP from HolidaySchedule where DateID = @Date_ID
GO

GRANT EXECUTE ON [Admin_Holiday_DateGet] TO ExecuteOnlyRole

GO
