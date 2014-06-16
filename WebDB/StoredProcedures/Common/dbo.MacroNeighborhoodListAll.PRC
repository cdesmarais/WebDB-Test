if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MacroNeighborhoodListAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MacroNeighborhoodListAll]
GO

CREATE Procedure dbo.MacroNeighborhoodListAll

--**********************************
--** Called by the CacheManager
--**********************************
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

	SELECT DISTINCT 
			mn.MacroID AS MacroNeighborhoodID
			,mn.LanguageID
			,mn.MacroName AS MacroNeighborhoodName
			,mn.SortOrder AS [SortOrder]
			,mn.MetroAreaID AS MetroAreaID
			,mn.MacroCenterLat
			,mn.MacroCenterLon
			,mn.MacroLatSpan
			,mn.MacroLonSpan
			,mn.MacroNameSEO
FROM		RestaurantVW r
inner join	MacroNeighborhoodAVW mn
on			mn.LanguageID = r.LanguageID
INNER JOIN	Neighborhood n 
ON			n.MacroID = mn.MacroID 
and			n.neighborhoodid=r.neighborhoodid
INNER JOIN	MetroArea ma
ON			ma.MetroAreaID = mn.MetroAreaID
WHERE		(mn.Active = 1) 
AND			r.RestStateID <> 4
ORDER BY	[SortOrder]

GO

GRANT EXECUTE ON [MacroNeighborhoodListAll] TO ExecuteOnlyRole

GO


