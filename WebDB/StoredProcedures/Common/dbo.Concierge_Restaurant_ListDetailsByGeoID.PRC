if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_ListDetailsByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_ListDetailsByGeoID]
GO

CREATE PROCEDURE dbo.Concierge_Restaurant_ListDetailsByGeoID
 (
  @GeoID int
 )
As


--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT r.RID AS RestaurantID,
r.RName AS RestaurantName,
r.Address1 AS Address,r.City,
r.State
,r.Zip AS Zip
,r.NeighborhoodID AS NeighborhoodID,
n.NbhoodName AS NeighborhoodName,
r.PriceQuartileID AS Price_Quartile_ID,
ft.FoodType AS FoodType,
CASE WHEN r.RestStateID = 1 
THEN CASE WHEN
((r.IsReachable = 1) or ( r.Allotment = 1 and r.RestStateID = 1)) 
THEN 1 ELSE 4 END ELSE r.RestStateID END
AS RestaurantState,
CASE WHEN r.RestStateID = 1 AND 
((r.IsReachable = 1) or
(r.Allotment = 1 and r.RestStateID = 1))
THEN 1 ELSE 0 END AS IsAvailable
FROM		RestaurantVW r
INNER JOIN	NeighborhoodAVW n 
ON			r.NeighborhoodID = n.NeighborhoodID 
and			r.LanguageID = n.LanguageID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
INNER JOIN	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID 
and			ft.LanguageID = r.LanguageID
WHERE (n.MetroAreaID = @GeoID) 
AND (fts.IsPrimary = 1) 
AND (r.RestStateID <> 4) 
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
ORDER BY IsAvailable DESC,r.RName
GO

GRANT EXECUTE ON [Concierge_Restaurant_ListDetailsByGeoID] TO ExecuteOnlyRole

GO
