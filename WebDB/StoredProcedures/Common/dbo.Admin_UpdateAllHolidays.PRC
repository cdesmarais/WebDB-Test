if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateAllHolidays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateAllHolidays]
GO

 

CREATE PROCEDURE dbo.Admin_UpdateAllHolidays 
(
  @HIDs nvarchar(255),
  @override bit
)

AS 

update holidays set override = @override 
where holidayid in (Select id from fIDStrToTab(@HIDs, ','))
 

GO

 

GRANT EXECUTE ON [Admin_UpdateAllHolidays ] TO ExecuteOnlyRole

 

GO


