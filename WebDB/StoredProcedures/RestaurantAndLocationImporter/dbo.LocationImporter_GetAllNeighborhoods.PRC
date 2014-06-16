if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LocationImporter_GetAllNeighborhoods]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LocationImporter_GetAllNeighborhoods]
GO

CREATE Procedure dbo.LocationImporter_GetAllNeighborhoods

As
SET NOCOUNT ON

select distinct 
	  n.NeighborhoodID
	 ,n.LanguageID,n.MetroAreaID
	 ,n.NbhoodName as Name
	 ,n.NbhoodSName as SortableName
	 ,n.MacroID 
	 ,n.NbHoodCenterLat as Latitude
	 ,n.NbHoodCenterLon as Longitude
	 ,n.NbHoodLatSpan as LatitudeSpan
	 ,n.NbHoodLonSpan as LongitudeSpan
	 ,n.IsGeoCity
	 ,ma.SupportedDomainID
	 ,n.Active
	 ,n.NbhoodNameSEO as NameSEO
	 ,n.NLURLPart1
	 ,n.NLURLPart2
from NeighborhoodAVW n
join MetroAreaAVW ma
on n.MetroAreaID = ma.MetroAreaID
and n.LanguageID = ma.LanguageID

GO

GRANT EXECUTE ON [LocationImporter_GetAllNeighborhoods] TO ExecuteOnlyRole

GO