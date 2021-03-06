if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNListAllActiveRestaurantIncentives]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNListAllActiveRestaurantIncentives]
GO

CREATE  PROCEDURE dbo.DNListAllActiveRestaurantIncentives

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

--Ratings data display
declare @ReviewInceptionDays int
declare @ReviewInceptionCutoffDate datetime

--ValueLookupMasterID for BlackListed Restaurants to suppress Next Available Button on results page.
declare @SuppressNextAvailButtonValueMasterID int = 56

--ValueLookupMasterID for ERB Search BlackListed Restaurants (checkavail messages to ERB are prohibited)
declare @ERBSearchBlacklistMasterID int = 66


--Ratings data display logic
select	@ReviewInceptionDays = ValueInt 
from	ValueLookup 
where	LKey = 'RestReviewInceptionDays' 
and		LType = 'WEBSERVER'

set		@ReviewInceptionDays = ISNULL(@ReviewInceptionDays, 30)
set		@ReviewInceptionCutoffDate = DATEADD(dd, @ReviewInceptionDays*-1, GETDATE())
	
select 
	i.RID as rid
	,r.RName as [rname]
	,ma.MetroAreaName as [MetroAreaName]
	,ma.MetroAreaID as MetroAreaID
	,i.incentiveid as [incentive_id]
	,i.IncentiveName as incentivename 
	,ds.DSchName as incentiveday
	,ds.DSchID as schedule_ID
	,ecpc.Cost as CostPerCover
	,i.amount as amount
	,i.Startdate as [startdate]
	,i.createdate as createdate
	,i.Enddate as enddate
	,i.StartTime as [starttime]
	,i.EndTime as endtime
	,datedisabled as datedisabled
	,convert(int,i.active) as IncentiveStatus
	,i.Startdate +  i.StartTime as incentivestart
	,i.Enddate + i.EndTime as incentiveend
	,n.MacroID as MacroID
	, (CASE WHEN LEFT(r.RSName, 4) = 'The ' THEN SUBSTRING(r.RSName, 5, Len(r.RSName)-4) ELSE r.RSNAME END) As RSNameSort
	, (CASE WHEN LEFT(r.RName, 4) = 'The ' THEN SUBSTRING(r.RName, 5, Len(r.RName)-4) ELSE r.RNAME END) As RNameSort
	,r.country as countryID
	,n.NeighborhoodID
	,n.NbhoodName as NeighborhoodName
	,n.NbhoodSName as NeighborhoodSName
	,ft.FoodTypeID as FoodTypeID
	,ft.FoodType AS FoodTypeName
	,ft.FoodTypeSName AS FoodTypeSName
	,(case when(r.PriceQuartileID=5) then 0 else r.PriceQuartileID end) as Price_Quartile_ID
	,(case when(coalesce(dffs.BlackListFlag, 0) = 1) then -1 
			when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0
			else coalesce(dffs.totaldffs, 0) end) as totaldffs
	,(case when (coalesce(dffs.BlackListFlag, 0) = 1) then -1 
			when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0 
			else coalesce(AverageOverallRating, 0) end) as AverageOverallRating
	,(case when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 1
			else 0 end) as RestaurantComingSoon
	,(CASE WHEN rcc.TotalSeatedStandardCovers IS NULL THEN 0 ELSE rcc.TotalSeatedStandardCovers END) as TotalSeatedStandardCovers
	,isnull(rpr.Rank, 800000) as POPRank
	,fpop.OverrideRank
	,fpop.OverrideDate
from IncentiveVW i
inner join DaySchedule ds
		on i.IncentiveDay = ds.DSchID
inner join ExtranetCostPerCover ecpc 
		on ecpc.Points = i.Amount
left join RestaurantCoverCounts rcc 
		on rcc.RID = i.RID
left join RestaurantPOPRankings rpr
		on rpr.rid = i.rid
left join FeaturedDIPOverride fpop
		on fpop.RID = i.RID
inner join RestaurantVW r 
		on i.RID = r.RID
		and r.RestStateID = 1
inner join NeighborhoodVW n 
		on r.NeighborhoodID = n.NeighborhoodID
inner join MetroAreaLocal ma
		on n.MetroAreaID = ma.MetroAreaID
		and r.LanguageID = ma.LanguageID
inner join FoodTypes fts
		on r.RID = fts.RID 
		and isPrimary = 1
inner join CusineToLeastSpecificMacroVW cm
		on cm.FoodTypeID = fts.FoodTypeID
inner join	FoodType ft
		on fts.FoodTypeID = ft.FoodTypeID 
		and ft.LanguageID = r.LanguageID
left join [dbo].[DFFDailySummaryRIDStatsHolding] dffs
		on r.rid = dffs.webrid
left join RestaurantJustAdded rja
		on r.rid = rja.rid
where i.active = 1
	 and i.LastMinutePopThresholdTime IS NULL
	 and (Enddate + EndTime) > getdate()
	 and (Startdate) < getdate()+1 

GROUP BY  i.RID
,r.RName
,ma.MetroAreaName
,i.incentiveid
,i.IncentiveName
,ds.DSchName
,ds.DSchID
,ecpc.Cost
,i.amount
,i.Startdate
,i.createdate
,i.Enddate
,i.StartTime
,i.EndTime
,i.datedisabled
,i.active
,ma.MetroAreaID
,n.MacroID
,r.RSName
,r.country
,n.NeighborhoodID
,n.NbhoodName
,n.NbhoodSName
,ft.FoodTypeID
,ft.FoodType
,ft.FoodTypeSName
,r.PriceQuartileID
,dffs.BlackListFlag
,dffs.totaldffs
,dffs.AverageOverallRating
,rcc.TotalSeatedStandardCovers
,rpr.Rank
,fpop.OverrideRank
,fpop.OverrideDate
,rja.DateAdded
order by	[MetroAreaName],
			[RName],
			[StartTime],
			[Startdate],
			[incentive_id]

GO

GRANT EXECUTE ON [DNListAllActiveRestaurantIncentives] TO ExecuteOnlyRole

GO