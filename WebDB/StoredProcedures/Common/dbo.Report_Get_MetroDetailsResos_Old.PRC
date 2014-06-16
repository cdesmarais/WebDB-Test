if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_MetroDetailsResos_Old]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_MetroDetailsResos_Old]
GO

CREATE Procedure dbo.Report_Get_MetroDetailsResos_Old
(
  @metroName int
)
AS

	exec dbo.Report_Get_MetroDetailsResos @metroName
GO


GRANT EXECUTE ON [Report_Get_MetroDetailsResos_Old] TO ExecuteOnlyRole

GO
