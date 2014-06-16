if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListDetailsByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListDetailsByGeoID]
GO

CREATE Procedure dbo.Restaurant_ListDetailsByGeoID
 (
  @GeoID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @time_offset   real
select  @time_offset = 3.0 
select  @time_offset = @time_offset / 24 / 60
 
SELECT r.RID AS RestaurantID
		,r.RName AS RestaurantName
		,r.Address1 AS Address
		,r.City
		,r.State
		,r.Zip AS Zip
		,r.NeighborhoodID AS NeighborhoodID
		,n.NbhoodName AS NeighborhoodName
		,r.PriceQuartileID as Price_Quartile_ID
		,ft.FoodType AS FoodType
		,CASE 
		   WHEN ((r.RestStateID = 1 AND r.IsReachable = 1) 
			  or (r.Allotment = 1)  AND(r.RestStateID = 1))
		   THEN 1 
		ELSE RestStateID   
		END AS RestaurantState
		,CASE 
		   WHEN ((r.RestStateID = 1 AND r.IsReachable = 1) 
			  or (r.Allotment = 1)  AND(r.RestStateID = 1))
		   THEN 1  
		ELSE 0 
		END AS IsAvailable

FROM       RestaurantVW r
INNER JOIN NeighborhoodAVW n 
ON         r.NeighborhoodID = n.NeighborhoodID 
and			r.LanguageID = n.LanguageID
INNER JOIN FoodTypes fts
ON         r.RID = fts.RID 
INNER JOIN FoodType ft
ON         fts.FoodTypeID = ft.FoodTypeID 
and			r.LanguageID = ft.LanguageID
WHERE     (n.MetroAreaID = @GeoID) 
AND       (fts.IsPrimary = 1) 
AND       (r.RestStateID in (1,5,6,13))
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
ORDER BY   IsAvailable 
          ,r.RName ASC
GO

GRANT EXECUTE ON [Restaurant_ListDetailsByGeoID] TO ExecuteOnlyRole

GO
