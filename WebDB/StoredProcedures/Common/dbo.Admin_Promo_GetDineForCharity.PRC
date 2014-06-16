if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promo_GetDineForCharity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promo_GetDineForCharity]
GO

CREATE PROCEDURE dbo.Admin_Promo_GetDineForCharity
(
  @MetroArea int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select 
				r.RID as Restaurant_ID
				,r.Rname as restname
				,m.MetroAreaName as metroarea
				,PriceQuartileID as Price_Quartile_ID
				,FoodType.FoodType as food
				,coalesce(PromoDineForCharity.RID,0) as promo
from			RestaurantVW r
left outer join PromoDineForCharity 
on				r.RID = PromoDineForCharity.RID
inner join		NeighborhoodAVW n 
on				n.neighborhoodid = r.neighborhoodid
and				n.LanguageID = r.LanguageID
inner Join		MetroAreaLocal m 
on				m.metroareaid = n.metroareaid
and				m.LanguageID = r.LanguageID
INNER JOIN		FoodTypes 
ON				r.RID = FoodTypes.RID 
and				FoodTypes.IsPrimary = 1
INNER JOIN		FoodType 
ON				FoodTypes.foodtypeID = FoodType.foodtypeID
AND				FoodType.LanguageID = r.LanguageID
where			m.metroareaid = @MetroArea
order by		restname

GO

GRANT EXECUTE ON [Admin_Promo_GetDineForCharity] TO ExecuteOnlyRole

GO
