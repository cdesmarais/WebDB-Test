if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoSvcCachePromoRestsLocalized]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].PromoSvcCachePromoRestsLocalized
GO

create procedure dbo.PromoSvcCachePromoRestsLocalized
as
set nocount on
set transaction isolation level read uncommitted

Select 
 dbo.fGetRegionID() as RegionID
 ,p.PromoID as promo  
 ,ma.MetroAreaID  
 ,r.RID as Restaurant_ID  
 ,p.LanguageID
 ,r.RName as restname  
 ,ft.FoodType as food  
 ,Coalesce(pr.Message,'') as promo_message  
 ,n.NbhoodName as neighborhood_name  
 , (CASE WHEN LEFT(r.RSName, 4) = 'The ' THEN SUBSTRING(r.RSName, 5, Len(r.RSName)-4) ELSE r.RSNAME END) As RSNameSort  
 , (CASE WHEN LEFT(r.RName, 4) = 'The ' THEN SUBSTRING(r.RName, 5, Len(r.RName)-4) ELSE r.RNAME END) As RNameSort  
 ,n.NbhoodSName as NeighborhoodSName  
 ,ft.FoodTypeSName AS FoodTypeSName
 ,ri.ThumbnailName  
from  PromoPages p  
inner join PromoRests pr  
on   p.PromoID = pr.PromoID  
inner join RestaurantAVW r  
on   pr.RID = r.RID  
and   p.LanguageID = r.LanguageID  
inner join NeighborhoodAVW n   
on   n.NeighborhoodID = r.NeighborhoodID  
and   n.LanguageID = p.LanguageID  
inner Join MetroAreaAVW ma  
on   ma.MetroAreaID = n.MetroAreaID  
and   ma.LanguageID = p.LanguageID  
INNER JOIN FoodTypes fts  
ON   r.RID = fts.RID   
and   fts.IsPrimary = 1  
INNER JOIN FoodType ft  
ON   fts.FoodTypeID = ft.FoodTypeID  
AND   ft.LanguageID = p.LanguageID  
INNER JOIN TimezoneVW tz  
ON   tz.TZID = ma.TZID  
LEFT JOIN RestaurantImage ri  
ON   r.RID = ri.RID  
LEFT JOIN [dbo].[DFFDailySummaryRIDStatsHolding] dffs  
ON   r.rid = dffs.webrid  

where  p.Active = 1  
and   r.RestStateID in (1, 13)
and   ma.Active = 1

go


grant execute on [PromoSvcCachePromoRestsLocalized] to ExecuteOnlyRole

GO

