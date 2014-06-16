if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_GetRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_GetRests]
GO

CREATE PROCEDURE dbo.Admin_Promos_Pages_GetRests
(
  @MetroArea int,
  @PromoID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select 
			r.RID as Restaurant_ID
			,r.Rname as restname
			,ma.MetroAreaName as metroarea
			,PriceQuartileID
			,FoodType.FoodType as food
			,Coalesce(PromoRests.PromoID,0) as promo
			,Coalesce(PromoRests.Message,'') as promo_message
			,Coalesce(PromoRests.shortdesc,'') as short
			,n.NbhoodName as neighborhood_name
			,Reserve
			,Coalesce(Rank,999) as Rank
			,Phone
from		RestaurantVW r
inner join	PromoRests 
on			r.RID = PromoRests.RID 
and			PromoRests.PromoID = @PromoID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner Join	MetroAreaAVW ma 
on			ma.metroareaid = n.metroareaid
and			ma.LanguageID = r.LanguageID
INNER JOIN	FoodTypes 
ON			r.RID = FoodTypes.RID 
and			FoodTypes.IsPrimary = 1
INNER JOIN	FoodType 
ON			FoodTypes.foodtypeID = FoodType.foodtypeID
AND			FoodType.LanguageID = r.LanguageID
where		ma.metroareaid = @MetroArea
order by	rank
			,restname

GO

GRANT EXECUTE ON [Admin_Promos_Pages_GetRests] TO ExecuteOnlyRole

GO
