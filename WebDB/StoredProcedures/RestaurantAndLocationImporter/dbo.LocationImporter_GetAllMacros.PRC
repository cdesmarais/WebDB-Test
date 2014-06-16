if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LocationImporter_GetAllMacros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LocationImporter_GetAllMacros]
GO

CREATE Procedure dbo.LocationImporter_GetAllMacros

As
SET NOCOUNT ON
set transaction isolation level read uncommitted

select distinct
	mn.MacroID AS MacroNeighborhoodID
	,mn.LanguageID
	,mn.MacroName AS MacroNeighborhoodName
	,mn.MetroAreaID AS MetroAreaID
	,mn.MacroCenterLat
	,mn.MacroCenterLon
	,mn.MacroLatSpan
	,mn.MacroLonSpan
	,mn.MacroNameSEO
	,ma.SupportedDomainID
	,mn.Active
	,mn.SortOrder
	,mn.NLURLPart1
	,mn.NLURLPart2
from MacroNeighborhoodAVW mn
join MetroAreaAVW ma
on mn.MetroAreaID = ma.MetroAreaID
and mn.LanguageID = ma.LanguageID

GO

GRANT EXECUTE ON [LocationImporter_GetAllMacros] TO ExecuteOnlyRole

GO


