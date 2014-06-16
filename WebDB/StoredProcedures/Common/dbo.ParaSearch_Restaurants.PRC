if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ParaSearch_Restaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ParaSearch_Restaurants]
GO

CREATE Procedure dbo.ParaSearch_Restaurants
 (
  @GeoID int,
  @Cuisine_ID int,
  @Offers_ID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if @Offers_ID = 0 and @Cuisine_ID = 0 
BEGIN

SELECT r.RID AS RestaurantID,r.Rname AS RestaurantName,MacroID as Macro_ID,r.neighborhoodid as neighborhood_ID,PriceQuartileID as Price_Quartile_ID
FROM		RestaurantVW r
INNER JOIN	NeighborhoodAVW n 
ON			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
WHERE		n.metroareaid = @GeoID and
			r.RestStateID = 1 AND 
			((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))
ORDER BY r.RName

END
else
BEGIN
	
	
	if @Offers_ID <> 0 and @Cuisine_ID <> 0
	BEGIN
		SELECT r.RID AS RestaurantID,r.Rname AS RestaurantName,MacroID as Macro_ID,r.neighborhoodid as neighborhood_ID,PriceQuartileID as Price_Quartile_ID
		FROM		RestaurantVW r
		INNER JOIN	NeighborhoodAVW n 
		ON			r.neighborhoodid = n.neighborhoodid
		and			r.LanguageID = n.LanguageID
		INNER JOIN	Offers 
		ON			r.RID = Offers.RID
		INNER JOIN	FoodTypes 
		ON			r.RID = FoodTypes.RID
		WHERE		n.metroareaid = @GeoID and
					r.RestStateID = 1 AND 
					((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))
		and			Offers.offerID = @Offers_ID and FoodTypes.foodtypeID = @Cuisine_ID
		ORDER BY r.RName
	END

	if @Offers_ID = 0
	BEGIN
		SELECT r.RID AS RestaurantID,r.Rname AS RestaurantName,MacroID as Macro_ID,r.neighborhoodid as neighborhood_ID,PriceQuartileID as Price_Quartile_ID
		FROM		RestaurantVW r
		INNER JOIN	NeighborhoodAVW n 
		ON			r.neighborhoodid = n.neighborhoodid
		and			r.LanguageID = n.LanguageID
		INNER JOIN	FoodTypes 
		ON			r.RID = FoodTypes.RID
		WHERE		n.metroareaid = @GeoID and
					r.RestStateID = 1 AND 
					((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))
		and			FoodTypes.foodtypeID = @Cuisine_ID
		ORDER BY r.RName
	END

	if @Cuisine_ID = 0
	BEGIN
		SELECT r.RID AS RestaurantID,r.Rname AS RestaurantName,MacroID as Macro_ID,r.neighborhoodid as neighborhood_ID,PriceQuartileID as Price_Quartile_ID
		FROM RestaurantVW r
		INNER JOIN	NeighborhoodAVW n 
		ON			r.neighborhoodid = n.neighborhoodid
		and			r.LanguageID = n.LanguageID
		INNER JOIN	Offers 
		ON			r.RID = Offers.RID
		WHERE		n.metroareaid = @GeoID and
					r.RestStateID = 1 AND 
					((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))
		and			Offers.offerID = @Offers_ID
		ORDER BY r.RName
	END


END
GO

GRANT EXECUTE ON [ParaSearch_Restaurants] TO ExecuteOnlyRole

GO
