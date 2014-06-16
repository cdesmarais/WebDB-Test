if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_MetroDetailsRegs_Old]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_MetroDetailsRegs_Old]
GO

CREATE PROCEDURE dbo.Report_Get_MetroDetailsRegs_Old
(
  @metroName int
)
AS

	exec Report_Get_MetroDetailsRegs @metroName 

GO


GRANT EXECUTE ON [Report_Get_MetroDetailsRegs_Old] TO ExecuteOnlyRole

GO
