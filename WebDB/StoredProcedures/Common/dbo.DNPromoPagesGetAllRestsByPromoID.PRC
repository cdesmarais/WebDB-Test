

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNPromoPagesGetAllRestsByPromoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNPromoPagesGetAllRestsByPromoID]
GO



CREATE PROCEDURE dbo.DNPromoPagesGetAllRestsByPromoID
(
  @PromoID int
)
AS

set transaction isolation level read committed
Select		r.RID as Restaurant_ID
			,r.RName as restname
			,ma.MetroAreaName as metroarea
			,(Case when(PriceQuartileID=5) then 0 else PriceQuartileID end) as Price_Quartile_ID
			,ft.FoodType as food
			,Phone
			,Coalesce(PromoPages.PromoID,0) as promo
			,Coalesce(PromoRests.Message,'') as promo_message
			,Coalesce(PromoRests.ShortDesc,'') as short
			,n.NbhoodName as neighborhood_name
			,Reserve
			,Coalesce(Rank,999) as Rank
			,PromoPages.PromoPageName as PromoName
			,ppst.SearchTypeName as PromoPageSearchType
			,ma.MetroAreaID
			,coalesce(RefCodePage,0) as RefCodePage
			,coalesce(RefCodeLink,0) as RefCodeLink
			,Lunch
			,Dinner
			,SelectionDate
			,co.CountryID
			,SuppressDIP
			,EventStartDate
			,EventEndDate
			,RestStateID 
			,isReachable 
from		RestaurantVW r
INNER JOIN	country co
on			co.countryid = r.country
inner join	PromoRests 
on			r.RID = PromoRests.RID
inner join	PromoPages 
on			PromoRests.PromoID = PromoPages.PromoID
inner join	PromoPagesSearchType ppst
on			ppst.SearchTypeid = PromoPages.PromoSearchTypeid	
inner join	NeighborhoodAVW n 
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = r.LanguageID
inner Join	MetroAreaAVW ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = r.LanguageID
INNER JOIN	FoodTypes 
ON			r.RID = FoodTypes.RID 
and			FoodTypes.IsPrimary = 1
INNER JOIN	FoodType ft
ON			FoodTypes.FoodTypeID = ft.FoodTypeID
and			ft.LanguageID = r.LanguageID
where		promopages.promoid = @PromoID
order by	metroarea asc, 
			restname asc
GO

GRANT EXECUTE ON [DNPromoPagesGetAllRestsByPromoID] TO ExecuteOnlyRole

GO


