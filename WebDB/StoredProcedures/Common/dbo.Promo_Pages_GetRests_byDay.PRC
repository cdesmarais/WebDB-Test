GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_Pages_GetRests_byDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_Pages_GetRests_byDay]
GO




CREATE PROCEDURE dbo.Promo_Pages_GetRests_byDay
(
  @MetroArea int,
  @PromoID int
)
AS

set transaction isolation level read uncommitted
set nocount on

Select 
			r.RID as Restaurant_ID
			,r.RName as restname
			,ma.MetroAreaName as metroarea
			,PriceQuartileID as Price_Quartile_ID
			,ft.FoodType as food
			,Phone
			,Coalesce(pr.PromoID,0) as promo
			,Coalesce(pr.Message,'') as promo_message
			,Coalesce(pr.ShortDesc,'') as short
			,n.NbhoodName as neighborhood_name,Reserve
			,Coalesce(Rank,999) as Rank
			,scheduleID as Schedule_ID
			,pr.Lunch
			,pr.Dinner
from		RestaurantVW r
inner join	PromoRests pr
on			r.RID = pr.RID 
and			pr.PromoID = @PromoID
inner join	PromoPages pp
on			pr.PromoID = pp.PromoID
inner join	NeighborhoodAVW n 
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = r.LanguageId
inner Join	MetroAreaLocal ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = r.LanguageID
left Join	PromoRestsDays prd
on			pr.RID = prd.RID 
and			prd.PromoID = @PromoID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
and			fts.IsPrimary = 1
INNER JOIN	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID
and			ft.LanguageID = r.LanguageID
left join	blockedDay bd 
on			r.rid = bd.RID 
and			left(SelectionDate,11)  = left(BlockedDate,11)
where		ma.MetroAreaID = @MetroArea 
and			RestStateID = 1 
and			IsReachable = 1
and			pr.PromoID = @PromoID
and 		(bd.blockedDate is null or pr.PromoID not in (4,5,6.7))
order by	Rank
		   ,restname


GO


GRANT EXECUTE ON [Promo_Pages_GetRests_byDay] TO ExecuteOnlyRole

GO

