--GEOGRAPHY REPORT
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_Geography]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_Geography]
GO

CREATE PROCEDURE dbo.Report_Restaurant_Geography
(
	@metroareaid int = null -- default is null, meaning all metro areas will be returned
)
AS

set transaction isolation level read uncommitted
set nocount on

SELECT 
			r.rid, 
			r.rname, 
			r.Address1 as [Street Address 1],
			r.Address2 as [Street Address 2],
			r.City,
			r.State,
			r.ZIP,
			r.Country,
			r.MappingAddress as [Mapping Street Address],
			r.Latitude, 
			r.Longitude, 
			m.Metroareaid, 
			m.metroareaname, 
			m.MetroCenterLat,
			m.MetroCenterLon, 
			mn.MacroName, 
			mn.MacroCenterLat, 
			mn.MacroCenterLon, 
			n.NbhoodName, 
			n.NBHoodCenterLat, 
			n.Nbhoodcenterlon,
			dbo.Haversine_Distance (r.latitude, r.longitude, m.MetroCenterLat, m.MetroCenterLon) AS MetroDistance,  -- distance from restaurant to metro center point
			dbo.Haversine_Distance (r.latitude, r.longitude, mn.MacroCenterLat, mn.MacroCenterLon) AS MacroDistance, -- distance from restaurant to macro center point
			dbo.Haversine_Distance (r.latitude, r.longitude, n.NBHoodCenterLat, n.Nbhoodcenterlon) AS NeighborhoodDistance, -- distance from restaurant to nbhood center point
			rs.RState
FROM 		RestaurantVw r
INNER JOIN 	NeighborhoodVw n
ON 			n.NeighborhoodID = r.NeighborhoodID
INNER JOIN 	MacroNeighborhoodVw mn
ON 			mn.MacroID = n.MacroID
INNER JOIN 	MetroAreaVw m
ON 			m.MetroAreaID = mn.MetroAreaID
INNER JOIN	RestaurantState rs
ON			r.RestStateID = rs.RestStateID
WHERE 		m.MetroAreaID = ISNULL(@metroareaid, m.MetroAreaID)
ORDER BY 	m.MetroAreaID, r.rname

GO

GRANT EXECUTE ON [Report_Restaurant_Geography] TO ExecuteOnlyRole
GO
