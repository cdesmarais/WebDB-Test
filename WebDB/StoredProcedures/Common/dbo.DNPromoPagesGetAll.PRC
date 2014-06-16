if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNPromoPagesGetAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNPromoPagesGetAll]
GO



CREATE PROCEDURE dbo.DNPromoPagesGetAll

AS

set transaction ISOLATION LEVEL read UNCOMMITTED

	--Ratings data display
	declare @ReviewInceptionDays int
	declare @ReviewInceptionCutoffDate datetime

	--Ratings data display logic
	select	@ReviewInceptionDays = ValueInt 
	from	ValueLookup 
	where	LKey = 'RestReviewInceptionDays' 
	and		LType = 'WEBSERVER'

	set		@ReviewInceptionDays = ISNULL(@ReviewInceptionDays, 30)
	set		@ReviewInceptionCutoffDate = DATEADD(dd, @ReviewInceptionDays*-1, GETDATE())

Select r.RID as Restaurant_ID
	,r.RName as restname
	,ma.MetroAreaName as metroarea
	,(Case when(PriceQuartileID=5) then 0 else PriceQuartileID end) as Price_Quartile_ID
	,ft.FoodType as food
	,Phone
	,Coalesce(p.PromoID,0) as promo
	,Coalesce(pr.Message,'') as promo_message
	,Coalesce(pr.ShortDesc,'') as short
	,n.NbhoodName as neighborhood_name
	,Reserve
	,Coalesce(Rank,999) as Rank
	,p.PromoPageName as PromoName
	,ma.MetroAreaID
	,coalesce(RefCodePage,0) as RefCodePage
	,coalesce(RefCodeLink,0) as RefCodeLink
	,Lunch
	,Dinner
	,SelectionDate
	,c.CountryID
	,SuppressDIP
	,EventStartDate
	,EventEndDate
	,RestStateID 
	,isReachable
	,RSname
	,sn.StateName
	,c.CountryName
	,c.SortOrder AS CountryOrder
	,c.CountrySName
	,ma.MetroAreaSName
	, (CASE WHEN LEFT(r.RSName, 4) = 'The ' THEN SUBSTRING(r.RSName, 5, Len(r.RSName)-4) ELSE r.RSNAME END) As RSNameSort
	, (CASE WHEN LEFT(r.RName, 4) = 'The ' THEN SUBSTRING(r.RName, 5, Len(r.RName)-4) ELSE r.RNAME END) As RNameSort
	,p.BeginDate	PromoBeginDate
	,p.EndDate		PromoEndDate
	,tz.currentLocalTime	CurrentLocalTime
	,p.SuppressPrice
	,n.MacroID
	,r.NeighborhoodID
	,n.NbhoodSName as NeighborhoodSName
	,ft.FoodTypeSName AS FoodTypeSName
	,ft.FoodTypeID as FoodTypeID
	,ri.ThumbnailName
	,(CASE WHEN(coalesce(dffs.BlackListFlag, 0) = 1) THEN -1
	  ELSE coalesce(dffs.totaldffs, 0) END) as totaldffs
	,(CASE WHEN (coalesce(dffs.BlackListFlag, 0) = 1) THEN -1 
	  ELSE coalesce(AverageOverallRating, 0) END) as AverageOverallRating
	,coalesce(rja.JustAdded, 0) as RestaurantJustAdded
from		PromoPages p
inner join dbo.DBUserDistinctLanguageVW db
on			db.languageid = p.LanguageID
inner join	PromoRests pr
on			p.PromoID = pr.PromoID
inner join	RestaurantAVW r
on			pr.RID = r.RID
and			p.LanguageID = r.LanguageID
inner join	dbo.CountryVW c
ON			r.Country = c.CountryID
inner join	NeighborhoodAVW n 
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = p.LanguageID
inner Join	MetroAreaAVW ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = p.LanguageID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
and			fts.IsPrimary = 1
INNER JOIN	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID
AND			ft.LanguageID = p.LanguageID
INNER JOIN	TimezoneVW tz
ON			tz.TZID = ma.TZID
LEFT OUTER JOIN	dbo.StateName sn
ON			r.State = sn.StateID
LEFT JOIN RestaurantImage ri
ON			r.RID = ri.RID
LEFT JOIN [dbo].[DFFDailySummaryRIDStatsHolding] dffs
ON			r.rid = dffs.webrid
LEFT JOIN [dbo].[RestaurantJustAdded] rja
ON			r.rid = rja.rid
LEFT JOIN RestaurantDFFCategoryCorrelation dfcc
on			r.RID = dfcc.RID
where		p.Active = 1
and			r.RestStateID != 4 --** Do not include inactive restaurnts
GO

GRANT EXECUTE ON [DNPromoPagesGetAll] TO ExecuteOnlyRole

GO

