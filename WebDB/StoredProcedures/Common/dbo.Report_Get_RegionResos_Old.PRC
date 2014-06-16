if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_RegionResos_Old]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_RegionResos_Old]
GO

CREATE PROCEDURE dbo.Report_Get_RegionResos_Old
(
  @area nvarchar(50) = Null
)
AS

	exec dbo.Report_Get_RegionResos @area

GO


GRANT EXECUTE ON [Report_Get_RegionResos_Old] TO ExecuteOnlyRole

GO
