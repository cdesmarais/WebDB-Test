
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllNeighborhood]
GO

CREATE procedure [dbo].[Admin_CacheAllNeighborhood]
AS
SET NOCOUNT ON

SELECT		n.neighborhoodid as NeighborhoodID,
			ma.MetroAreaName as GeoName,  
			n.NbhoodName as NeighborhoodName, 
   ma.MetroAreaName+' > '+ mn.[MacroName] + ' > ' + n.NbhoodName as NeighborhoodDisplayName,  
			n.LanguageID AS LanguageID,
			ma.SupportedDomainID as DomainID,
			d.PrimaryLanguageID,
			mn.[MacroName],
			mn.[MacroID],
			n.[MetroAreaID],
			(CASE WHEN n.[Active] = 1 THEN 'Active' ELSE 'Inactive' END) AS NBActiveText,
			n.Active as NActive,
			mn.active as MNActive,
			ma.active as MAActive,
			ma.CountryID as CountryID
FROM		NeighborhoodAVW n 
INNER JOIN	MacroNeighborhoodAVW mn
ON			mn.MacroID = n.MacroID
AND			mn.LanguageID = n.LanguageID
INNER JOIN	MetroAreaAVW ma
ON			ma.metroareaid = n.metroareaid
AND			ma.LanguageID = n.LanguageID
INNER JOIN	Domain d
ON		ma.SupportedDomainID = d.DomainID
ORDER BY	ma.SupportedDomainID, LanguageID, ma.MetroAreaName
			,n.NbhoodName
			

GO

GRANT EXECUTE ON [Admin_CacheAllNeighborhood] TO ExecuteOnlyRole
GO
