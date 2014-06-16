
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllRegions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllRegions]
GO


CREATE PROCEDURE dbo.Admin_CacheAllRegions

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	Select	MacroID,
			MacroName,
			mn.LanguageID,
			SupportedDomainID,
			PrimaryLanguageID,
			mn.MetroAreaID,
			mn.Active
	From	MacroNeighborhoodAVW mn
	INNER JOIN MetroAreaAVW ma  
	ON   ma.metroareaid = mn.metroareaid  
	AND   ma.LanguageID = mn.LanguageID  
	Order By mn.metroareaid Asc, MacroName Asc


GO

GRANT EXECUTE ON [Admin_CacheAllRegions] TO ExecuteOnlyRole

GO
