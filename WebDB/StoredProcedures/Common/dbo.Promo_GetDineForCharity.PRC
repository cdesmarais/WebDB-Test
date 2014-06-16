if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetDineForCharity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetDineForCharity]
GO

CREATE PROCEDURE dbo.Promo_GetDineForCharity
(
  @MetroArea nvarchar(50)
)
AS

set transaction isolation level read uncommitted

Select 
			r.RID as Restaurant_ID
			,r.Rname as restname
			,ma.MetroAreaName as metroarea
			,PriceQuartileID as Price_Quartile_ID
			,FoodType.FoodType as food 
from		RestaurantVW r
inner join	PromoDineForCharity 
on			r.RID = PromoDineForCharity.RID
inner join	Neighborhood n 
on			r.neighborhoodid = n.neighborhoodid
inner Join	MetroAreaLocal ma
on			n.metroareaid = ma.metroareaid
and			ma.LanguageID = r.LanguageID
INNER JOIN	FoodTypes 
ON			r.RID = FoodTypes.RID 
and			FoodTypes.IsPrimary = 1
INNER JOIN	FoodType 
ON			FoodTypes.foodtypeID = FoodType.foodtypeID
and			FoodType.LanguageID = r.LanguageID
where  (LEN(@MetroArea) = 0 OR CHARINDEX(',' + CAST(ma.MetroAreaID AS nvarchar(16)) + ',',',' + @MetroArea + ',') > 0)

order by restname

GO

GRANT EXECUTE ON [Promo_GetDineForCharity] TO ExecuteOnlyRole

GO
