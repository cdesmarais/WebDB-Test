if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminUpdateHoliday]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminUpdateHoliday]
GO

 

CREATE PROCEDURE dbo.AdminUpdateHoliday 
(
  @HID int,
  @override bit
)

AS 

update holidays set override = @override 
where holidayid = @HID

 

 

 

GO

 

GRANT EXECUTE ON [AdminUpdateHoliday ] TO ExecuteOnlyRole

 

GO


