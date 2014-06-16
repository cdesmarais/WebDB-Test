if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoSvcCachePromoRestsUniversal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].PromoSvcCachePromoRestsUniversal
GO

create procedure dbo.PromoSvcCachePromoRestsUniversal
as
set nocount on
set transaction isolation level read uncommitted

Select 
 dbo.fGetRegionID() as RegionID
 ,p.PromoID as promo  
 ,ma.MetroAreaID  
 ,r.RID as Restaurant_ID  
 ,(Case when(PriceQuartileID=5) then 0 else PriceQuartileID end) as Price_Quartile_ID  
 ,coalesce(RefCodePage,0) as RefCodePage  
 ,Lunch  
 ,Dinner  
 ,SelectionDate  
 ,p.BeginDate PromoBeginDate  
 ,p.EndDate  PromoEndDate  
 ,tz.currentLocalTime CurrentLocalTime  
 ,n.MacroID  
 ,r.NeighborhoodID  
 ,ft.FoodTypeID as FoodTypeID  
 ,(CASE WHEN(coalesce(dffs.BlackListFlag, 0) = 1) THEN -1  
   ELSE coalesce(dffs.totaldffs, 0) END) as totaldffs  
 ,(CASE WHEN (coalesce(dffs.BlackListFlag, 0) = 1) THEN -1   
   ELSE coalesce(AverageOverallRating, 0) END) as AverageOverallRating  
 ,coalesce(pdse.SupressDIPLunch, p.SuppressDIP) as SuppressDIPLunch
 ,coalesce(pdse.SupressDIPDinner, p.SuppressDIP) as SuppressDIPDinner
 ,CASE WHEN holiday.HolidayID IS NULL THEN 0 ELSE 1 END IsHoliday
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
LEFT JOIN [dbo].[DFFDailySummaryRIDStatsHolding] dffs  
ON   r.rid = dffs.webrid  
LEFT JOIN PromoDIPSupressExclusion pdse
ON p.PromoID = pdse.PromoID and pr.RID = pdse.RID
LEFT JOIN HolidaySchedule holiday
ON (DATEDIFF(dd,p.EventStartDate,p.EventEndDate)=1 
	AND (p.EventStartDate = holiday.HolidayDate) 
	AND (r.Country = CASE WHEN holiday.CountryID = 'ALL' THEN r.Country ELSE holiday.CountryID END))

where  p.Active = 1  
and   r.RestStateID in (1, 13)
and   ma.Active = 1

go


grant execute on [PromoSvcCachePromoRestsUniversal] to ExecuteOnlyRole

GO

