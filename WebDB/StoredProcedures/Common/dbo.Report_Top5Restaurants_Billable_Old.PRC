if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Top5Restaurants_Billable_Old]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Top5Restaurants_Billable_Old]
GO

CREATE Procedure dbo.Report_Top5Restaurants_Billable_Old
AS

	exec dbo.Report_Top5Restaurants_Billable
GO


GRANT EXECUTE ON [Report_Top5Restaurants_Billable_Old] TO ExecuteOnlyRole

GO
