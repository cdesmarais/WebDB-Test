if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesGetRestsAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesGetRestsAll]
GO



CREATE PROCEDURE dbo.AdminPromosPagesGetRestsAll
(
  @MetroArea int,
  @PromoID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

Select		r.RID as Restaurant_ID
			,r.Rname as restname
			,ma.MetroAreaName as metroarea
			,COALESCE(PromoRests.PromoID,0) as promo
			,COALESCE(PromoRests.Message,'') as promo_message
			,n.NbhoodName as neighborhood_name
			,COALESCE(Rank,999) as Rank
			,lunch
			,dinner
			,r.RestStateID AS RestaurantState
			,COALESCE(PromoPagesToMetro.MetroID,0) as MetroID
			,COALESCE(PDE.SupressDIPLunch,PP.SuppressDIP) as SupressDIPLunch
			,COALESCE(PDE.SupressDIPDinner,PP.SuppressDIP) as SupressDIPDinner
			,PP.SuppressDIP
			,r.RSName
from		RestaurantVW r
left join	PromoRests 
on			r.RID = PromoRests.RID 
and			PromoRests.PromoID = @PromoID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner Join	MetroAreaAVW ma
on			ma.metroareaid = n.metroareaid
and			ma.LanguageID = r.LanguageID
left outer	join PromoPagesToMetro 
on			n.metroareaid  = PromoPagesToMetro.MetroID 
and			PromoPagesToMetro.PromoID = @PromoID  
and			PromoPagesToMetro.MetroID = @MetroArea
LEFT JOIN	 PromoDIPSupressExclusion PDE
ON			(r.RID = PDE.RID and PDE.PromoID=@PromoID)
LEFT JOIN	PromoPages PP
ON			(PP.PromoID = @PromoID)
where		ma.metroareaid = @MetroArea 
and			r.RestStateID not in (2,3,4,8) 
order by	rank ,r.RSName, restname


GO

GRANT EXECUTE ON [AdminPromosPagesGetRestsAll] TO ExecuteOnlyRole

GO
