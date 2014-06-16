if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Neighborhood_ListWithGeoName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Neighborhood_ListWithGeoName]
GO

-- This proc is used by CHARM to pull data of Neighborhood with the Geographic location  
-- It is exclusively used by the new edit profile control.   
  
CREATE PROCEDURE [dbo].[Admin_Neighborhood_ListWithGeoName]  
As  
set nocount on  
set transaction isolation level read uncommitted  
  
select		n.neighborhoodid as NeighborhoodID,  
			ma.MetroAreaName as GeoName,  
			n.NbhoodName as NeighborhoodName, 
			ma.MetroAreaName+'('+ n.NbhoodName + ')' as NeighborhoodDisplayName 
from		NeighborhoodVW n 
inner join	MetroAreaAVW ma
on			ma.metroareaid = n.metroareaid
and			ma.LanguageID = n.LanguageID
where		n.Active = 1 or ma.metroareaid = 1
order by	ma.MetroAreaName
			,n.NbhoodName
GO

GRANT EXECUTE ON [Admin_Neighborhood_ListWithGeoName] TO ExecuteOnlyRole

GO

