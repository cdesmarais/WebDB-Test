if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_Private_Dining_Enabled_Restaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_Private_Dining_Enabled_Restaurants]
GO

CREATE PROCEDURE dbo.Job_Private_Dining_Enabled_Restaurants

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT r.RID, 
	RName, 
	MetroAreaName, 
	MacroName, 
	NbhoodName,
	OTPrice.PriceQuartile as Price,
	OTFood.FoodType as FoodType,
	MAX(UpdateLogDTUTC) AS Published,
	(SELECT		MAX(UpdateLogDTUTC) 
		FROM	PrivateDiningUpdateLog 
		WHERE	r.rid = PrivateDiningUpdateLog.rid 
		AND		UpdatedValues LIKE '%Published%False%Published%') AS Unpublished
FROM	PrivateDiningUpdateLog
INNER JOIN	dbo.RestaurantVW r 
ON			dbo.PrivateDiningUpdateLog.RID = r.RID
INNER JOIN	dbo.NeighborhoodVW n 
ON			r.NeighborhoodID = n.NeighborhoodID
INNER JOIN	dbo.MetroAreaVW m 
ON			n.MetroAreaID = m.MetroAreaID
INNER JOIN	dbo.MacroNeighborhoodVW ma 
ON			n.MacroID = ma.MacroID
INNER JOIN	PriceQuartileAVW OTPrice
ON			r.PriceQuartileID=OTPrice.PriceQuartileID 
AND			r.Country = OTPrice.CountryID
and			r.LanguageID = OTPrice.LanguageID
inner join FoodTypes OTFoods 
on			r.RID = OTFoods.RID AND IsPrimary = 1
inner join	FoodType OTFood 
on			OTFoods.FoodTypeID = OTFood.FoodTypeID
and			OTFood.LanguageID = r.LanguageID
WHERE		UpdatedValues LIKE '%Published%True%Published%'
GROUP BY	r.RID, 
			RName, 
			MetroAreaName, 
			MacroName, 
			NbhoodName, 
			OTPrice.PriceQuartile,
			OTFood.FoodType 

GO


GRANT EXECUTE ON [Job_Private_Dining_Enabled_Restaurants] TO ExecuteOnlyRole

GO
