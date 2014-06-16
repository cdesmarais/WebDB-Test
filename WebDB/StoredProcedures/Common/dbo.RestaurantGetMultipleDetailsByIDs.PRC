if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantGetMultipleDetailsByIDs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantGetMultipleDetailsByIDs]
GO

CREATE Procedure dbo.RestaurantGetMultipleDetailsByIDs
(
  @RestID nvarchar(2000)
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 
			r.RID AS RestaurantID
			,r.RName AS Name
			,r.Address1 AS Address
			,r.City
			,r.State
			,r.Zip AS Zip
			,r.NeighborhoodID AS NeighborhoodID
			,n.NbhoodName AS NeighborhoodName
			,r.PriceQuartileID as Price_Quartile_ID
			,ft.FoodType AS FoodType
			,CASE 
			   WHEN ((r.IsReachable = 1) or (r.Allotment = 1)) 
				AND (r.RestStateID = 1)
			   THEN 1 
			   ELSE RestStateID 
			 END AS RestaurantState
			,CASE 
			   WHEN ((r.IsReachable = 1) or (r.Allotment = 1)) 
				AND (r.RestStateID = 1)
			   THEN 1 
			   ELSE 0 
			 END AS IsAvailable
			 ,ma.MetroAreaName

FROM		RestaurantVW r
INNER JOIN	NeighborhoodAVW n 
ON			n.NeighborhoodID = r.NeighborhoodID 
and			n.LanguageID = r.LanguageID
INNER JOIN	MetroAreaAVW ma
ON			ma.MetroAreaID = n.MetroAreaID 
and			ma.LanguageID = r.LanguageID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
INNER JOIN	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID 
AND			ft.LanguageID = r.LanguageID
INNER JOIN ERBRestaurant 
ON			r.RID = ERBRestaurant.RID
WHERE		(fts.IsPrimary = 1) 
AND			(r.RestStateID in (1,5,6))
and			CHARINDEX(',' + CAST(r.RID AS nvarchar(5))
            + ',',',' + @RestID + ',') > 0
Order By	Name
GO

GRANT EXECUTE ON [RestaurantGetMultipleDetailsByIDs] TO ExecuteOnlyRole

GO
