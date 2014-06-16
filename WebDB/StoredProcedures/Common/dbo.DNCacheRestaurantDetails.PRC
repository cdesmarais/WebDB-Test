if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantDetails]
GO

CREATE Procedure dbo.DNCacheRestaurantDetails
As

	set transaction isolation level read uncommitted
	set nocount on

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

SELECT 
			r.RID as  RestaurantID
			,r.RName AS RestaurantName
			,r.RSName
			,r.RestaurantType
			,r.Address1 AS Address1
			,r.Address2 AS Address2
			,r.MappingAddress as MappingAddress
			,r.MapAddrValid as MapAddrValid
			,r.City
			,r.State
			,r.Zip AS Zip
			,co.countryID
			,co.countryCode
			,co.countryName				
			,r.ExternalURL AS URL
			,r.MenuURL
			,RestaurantState.RState AS RestaurantState
			,coalesce(rm.Message,'') as Description
			,r.Phone
			,r.AcceptCheque As Cheque
			,r.AcceptFlower as Flowers
			,r.AcceptGift as Gifts
			,mn.MetroAreaID as Metro_Area_ID
			,r.RestStateID as RestStateID
			,coalesce(r.CrossStreet,'') As CrossStreet
			,coalesce(p.Parking,'') As Parking
		,(SELECT mao.Days FROM MaxAdvanceOption mao WHERE  r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID) AS MaxAdvanceDays
		,r.NeighborhoodID AS NeighborhoodID
		,n.NbhoodName AS NeighborhoodName
		,n.NbhoodSName AS NeighborhoodSName
		,n.MacroID as MacroID
		,(Case when(r.PriceQuartileID=5) then 0 else r.PriceQuartileID end) AS Price_Quartile_ID
		,ft.FoodType AS FoodType
		,ft.FoodTypeSName AS FoodTypeSName
		,ft.FoodTypeID as FoodTypeID
		,CASE 
		   WHEN (r.RestStateID = 1 AND r.IsReachable = 1)
	  		THEN 1 
		   ELSE 0 
		 END AS IsAvailable
		,r.IsReachable as HasHeartbeat
		,r.ReserveCode
		,r.latitude
		,r.longitude
		,mn.MacroName
		,mn.SortOrder
		,coalesce(ri.Logo,'0') as RestaurantLogo
		, cm.SearchFoodTypeID
		, r.MinOnlineOptionID as MinPartySize
		, r.MaxLargePartyID AS MaxPartySize
		, r.DiningStyleID
		, l.LanguageID
		, l.LanguageCode
		, r.DomainID
		, r.CreateDate
		, (CASE WHEN LEFT(r.RSName, 4) = 'The ' THEN SUBSTRING(r.RSName, 5, Len(r.RSName)-4) ELSE r.RSNAME END) As RSNameSort
		, (CASE WHEN LEFT(r.RName, 4) = 'The ' THEN SUBSTRING(r.RName, 5, Len(r.RName)-4) ELSE r.RNAME END) As RNameSort
		, n.NbHoodCenterLat
		, n.NbHoodCenterLon
		, rp.City as MappingCity
		, n.NbHoodLatSpan
		, n.NbHoodLonSpan		
		,coalesce(LargestCapacity,0) AS LargestCapacity
		,(CASE WHEN(coalesce(dffs.BlackListFlag, 0) = 1) THEN -1
		  ELSE coalesce(dffs.totaldffs, 0) END) as totaldffs
		,(CASE WHEN (coalesce(dffs.BlackListFlag, 0) = 1) THEN -1 
		  ELSE coalesce(AverageOverallRating, 0) END) as AverageOverallRating
		,coalesce(rja.JustAdded, 0) as RestaurantJustAdded
		,rja.DateAdded as RestaurantInstallDate			
        , r.Allotment as Allotment
        ,r.AdWordsID
        ,r.AdWordsValue
		,ri.Thumbnail as RestaurantImageThumbnail
		,dfcc.ClusterID as CategoryCluster
		,dfcc.CorrelationToSeed
		,dfcc.IsOutlier as ClusterOutlier
		,ri.ThumbnailName
		,case when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 1
			else 0 end as RestaurantComingSoon
		,n.NbhoodNameSEO 
		,n.IsGeoCity
		,r.BrandID
		,r.FacebookURL
		,r.ShowFaceBookLikeBox
		,r.ShowThirdPartyMenu
		,r.IsConnectFieldTest
		,CASE
			WHEN r.IsConnectFieldTest = 1 THEN 12	 -- OTDatabase enum value for OTAvailability_FT
			WHEN r.RestaurantType = 'A' THEN 6		 -- OTDatabase enum value for OTAvailability
			ELSE NULL								 -- Not a Connect RID
		 END AS OTAInstanceID
		 ,coalesce(rmenu.IsAccessible, 0) as MenuURLAccessible
		 ,coalesce(rmenu.MenuFormatID, 0) as MenuFormatID
		 ,coalesce(rmf.MenuDisplayFormatID,0) AS MenuDisplayFormat
		 ,r.UpdatedDtUTC
		 ,r.PrivatePartyEmail as Email
		 ,rtf.TreatfulURL
		 ,CASE 
			  WHEN excl.RID is not null
			  THEN 1 
			  ELSE 0 
			END AS IsExcludedFromPartnerFeed
		 ,n.NLURLPart1
		 ,n.NLURLPart2 
	FROM		RestaurantVW r
	INNER JOIN	countryAVW co
	on			co.countryid = r.country
	and			co.LanguageID = r.LanguageID
	INNER JOIN RestaurantState 
	ON			 r.RestStateID = RestaurantState.RestStateID
	INNER JOIN NeighborhoodAVW n 
	ON			r.NeighborhoodID = n.NeighborhoodID
	and			r.LanguageID = n.LanguageID
	INNER JOIN MacroNeighborhoodAVW mn 
	ON			mn.MacroID = n.MacroID
	and			mn.LanguageID = r.LanguageID
	INNER JOIN MetroareaAVW mt 
	ON			mt.MetroareaID = n.MetroareaID
	and			mt.LanguageID = r.LanguageID
	LEFT JOIN RestaurantCustomMessage rm 
	ON			r.RID = rm.RID 
	and			r.LanguageID = rm.LanguageID
	and			rm.messageTypeID = 51	--Restaurant Description
	Left JOIN ParkingLocal p 
	ON			r.ParkingID = p.ParkingID
	and			r.LanguageID = p.LanguageID
	INNER JOIN FoodTypes fts
	ON			r.RID = fts.RID 
	AND			isPrimary = 1
	INNER JOIN CusineToLeastSpecificMacroVW cm
	ON			cm.FoodTypeID = fts.FoodTypeID
	INNER JOIN	FoodType ft
	ON			fts.FoodTypeID = ft.FoodTypeID 
	AND			ft.LanguageID = r.LanguageID
	INNER JOIN	Language l
	on			l.LanguageID = r.LanguageID
	INNER JOIN	Domain d
	ON			R.DomainID = d.DomainID
	INNER JOIN	RestaurantLocal rp
	ON			r.RID = rp.RID
	AND			d.PrimaryLanguageID = rp.LanguageID
	LEFT JOIN RestaurantImage ri
	ON			r.RID = ri.RID
	LEFT JOIN [dbo].[DFFDailySummaryRIDStatsHolding] dffs
	ON			r.rid = dffs.webrid
	LEFT JOIN [dbo].[RestaurantJustAdded] rja
	ON			r.rid = rja.rid
	LEFT JOIN RestaurantDFFCategoryCorrelation dfcc
	on			r.RID = dfcc.RID
	LEFT JOIN RestaurantMenuAccess rmenu
	on 			r.RID = rmenu.RID
	LEFT JOIN RestaurantMenuFormat rmf
	on 			rmenu.MenuFormatID = rmf.MenuFormatID
	LEFT JOIN RestaurantTreatful rtf
	on			r.RID = rtf.RID
	LEFT JOIN [dbo].[PartnerFeedExclusionList] excl
	on			r.RID = excl.RID
	Where r.RestStateID not in (4,11,15)  /* Per TT #31910 filter all restaurants with "Decline Online w/Conn" (11) and "Decline Online w/o Conn" (15) status */
	ORDER BY RSNameSort Asc, RNameSort ASC

GO

GRANT EXECUTE ON [DNCacheRestaurantDetails] TO ExecuteOnlyRole

GO
