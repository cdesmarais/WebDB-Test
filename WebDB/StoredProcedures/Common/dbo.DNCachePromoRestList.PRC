if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePromoRestList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePromoRestList]
GO

CREATE Procedure dbo.DNCachePromoRestList
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select r.RID as Restaurant_ID
	,r.RName as [restname]
	,ma.MetroAreaName as metroarea
	,r.PriceQuartileID as Price_Quartile_ID
	,ft.FoodType as food
	,r.Phone
	,Coalesce(pp.PromoID,0) as promo
	,Coalesce(pr.Message,'') as promo_message
	,Coalesce(pr.ShortDesc,'') as short
	,n.NbhoodName as neighborhood_name
	,Coalesce(Rank,999) as [Rank]
	,pp.PromoPageName as PromoName
	,n.MetroAreaID
	,pp.PromoID
	,PromoSearchTypeID
	,PromoIcon
	,IconBoldText
	,coalesce(RefCodePage,0) as RefCodePage
	,coalesce(RefCodeLink,0) as RefCodeLink

from		RestaurantVW r
inner join	PromoRests pr
on			r.RID = pr.RID
inner join	PromoPages pp
on			pr.PromoID = pp.PromoID
inner join	NeighborhoodAVW n 
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = r.LanguageID
inner Join	MetroAreaLocal ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = r.LanguageID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
and			fts.IsPrimary = 1
INNER JOIN	FoodType ft
ON			ft.FoodTypeID = fts.FoodTypeID
and			ft.LanguageID = r.LanguageID
where		r.RestStateID = 1 
and			r.IsReachable = 1
and			pp.Active = 1
order by	[Rank]
			,[restname]
GO

GRANT EXECUTE ON [DNCachePromoRestList] TO ExecuteOnlyRole

GO
