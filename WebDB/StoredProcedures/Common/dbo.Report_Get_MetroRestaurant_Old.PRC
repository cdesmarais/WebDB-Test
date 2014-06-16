if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_MetroRestaurant_Old]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_MetroRestaurant_Old]
GO

CREATE PROCEDURE dbo.Report_Get_MetroRestaurant_Old
(
  @metroName int
)
AS

	exec dbo.Report_Get_MetroRestaurant @metroName 
	
GO


GRANT EXECUTE ON [Report_Get_MetroRestaurant_Old] TO ExecuteOnlyRole

GO
