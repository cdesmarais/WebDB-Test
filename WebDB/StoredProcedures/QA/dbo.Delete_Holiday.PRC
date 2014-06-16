if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_Holiday]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_Holiday]
GO


CREATE PROCEDURE dbo.Delete_Holiday
(
    @HolidayID int
)

AS

Delete from HolidaySchedule where HolidayID = @HolidayID
Delete from HolidaysLocal where HolidayID = @HolidayID
Delete from Holidays where HolidayID = @HolidayID



GO

GRANT EXECUTE ON [Delete_Holiday] TO ExecuteOnlyRole

GO
