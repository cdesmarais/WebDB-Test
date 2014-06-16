if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNPromoPagesGetRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNPromoPagesGetRests]
GO

CREATE PROCEDURE dbo.DNPromoPagesGetRests
(
  @MetroArea int,
  @PromoID int
)
AS

set transaction isolation level read uncommitted

Select r.RID as Restaurant_ID
	,r.RName as restname
	,ma.MetroAreaName as metroarea
	,PriceQuartileID as Price_Quartile_ID
	,FoodType.FoodType as food,Phone
	,Coalesce(PromoPages.PromoID,0) as promo
	,Coalesce(PromoRests.Message,'') as promo_message
	,Coalesce(PromoRests.ShortDesc,'') as short
	,n.NbhoodName as neighborhood_name
	,Reserve
	,Coalesce(Rank,999) as Rank
	,PromoPages.PromoPageName as PromoName
from RestaurantVW r
inner join PromoRests 
		on r.RID = PromoRests.RID 
		and PromoRests.PromoID = @PromoID
inner join PromoPages 
		on PromoRests.PromoID = PromoPages.PromoID
inner join NeighborhoodAVW n 
		on r.NeighborhoodID = n.NeighborhoodID
		and	n.LanguageID = r.LanguageID
inner Join MetroAreaAVW ma 
		on n.MetroAreaID = ma.MetroAreaID
		and ma.LanguageID = r.LanguageID
INNER JOIN FoodTypes 
		ON r.RID = FoodTypes.RID 
		and FoodTypes.IsPrimary = 1
INNER JOIN FoodType 
		ON FoodTypes.FoodTypeID = FoodType.FoodTypeID
		and FoodType.LanguageID = r.LanguageID
where ma.MetroAreaID = @MetroArea 
	and RestStateID = 1 
and		IsReachable = 1
order by Rank
,restname

GO

GRANT EXECUTE ON [DNPromoPagesGetRests] TO ExecuteOnlyRole

GO
