if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantSearchList_v3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantSearchList_v3]
go

--*********************************************************
--** Retrieves a list of RID, with connection information, 
--** foodtype, price, neighborhood, etc... data
--** Intended to be joined with:  DNRestaurantSearchTime
--**
--** NOTE: Dataset is a complete list of restaurants that 
--** are in any of the following states: (1,2,5,6,7,13)
--** RestaurantState and Reachability will be updated at runtime
--**
--** EV: 09/23/04: Added IPAddress and Port, to select statement 
--**     used for improved performance of web site when data is cached
--**
--** EV: 09/28/05: Removed Before, Exact, After; Fields added at runtime
--**
--** Removed    I1, I2, I3, P1, P2, P3 fields not necessary
--** MMC: 3/3/08: Added OverrideRank, OverrideDate for FeaturedDIP per TT 22633
--** NC:08/20/08: Added diningstyleid, macroID columns for Mapping feature.
--** MMC: 3/12/09: Added TotalSeatedStandardCovers for FeaturedDIP per TT 28244
--** MMC: 4/20/09: Changed MaxOnlineOption to MinCCOption per TTT 25524
--** GG: 9/1/09: Added RestaurantImage for mobile search results per TT32743
--** NC:10/19/09:Added new columns to procedure: total dffs, AverageOverallRating,RestaurantComingSoon.
--** RK:05/11/2010:Added POPRank for FeaturedPOP using Conversion 
--** RK:01/10/2013 Added CutOff Days configurable by RID and Action(Make,Change,Cancel,Search)
--**	We have added the logic to look at ReviewInceptionDays to implement coming soon logic for restaurants
--**	with no dff data on new search results page.
--**	Also sort results based on ratings, showing coming soon restaurants to the bottom. 
--*********************************************************

create procedure dbo.DNCacheRestaurantSearchList_v3
as

	set transaction isolation level read uncommitted
	set nocount on
		
	--Ratings data display
	declare @ReviewInceptionDays int
	declare @ReviewInceptionCutoffDate datetime
	
	--ValueLookupMasterID for BlackListed Restaurants to suppress Next Available Button on results page.
	declare @SuppressNextAvailButtonValueMasterID int = 56
	
	--ValueLookupMasterID for ERB Search BlackListed Restaurants (checkavail messages to ERB are prohibited)
	declare @ERBSearchBlacklistMasterID int = 66
	declare @EarlyCutoffRIDWhitelistMasterID int = 89
	declare @UmamiWhitelistMasterID int = 90
	declare @FoodSpottingOptOut int = 63
	
	--Ratings data display logic
	select	@ReviewInceptionDays = ValueInt 
	from	dbo.ValueLookup 
	where	LKey = 'RestReviewInceptionDays' 
	and		LType = 'WEBSERVER'

	set		@ReviewInceptionDays = ISNULL(@ReviewInceptionDays, 30)
	set		@ReviewInceptionCutoffDate = DATEADD(dd, @ReviewInceptionDays*-1, GETDATE())

	select		 r.RID as RestaurantID
				,r.RName as RestaurantName
				,r.RSName
				, (case when (charindex(':',serverIP) > 0)
					then substring(serverIP, 1, charindex(':',er.serverIP)-1) 
					else ''
					end) as IPAddress
				, (case when (charindex(':',serverIP) > 0)
					then cast(substring(serverIP, charindex(':',er.serverIP)+1, 10) as int)
					else -1
					end) as Port
				,er.ServerIP as NetAddress
				,er.serverPwd as Password
				,er.ListenerVersion Orig_ListenerVersion  -- DataTable alread contains a ListenerVersion that is populated after com with erb
				,r.MinOnlineOptionID as MinPartySize
				,r.MinCCOptionID as MinCCPartySize
				,n.metroareaid as metroareaid
				,n.NBHoodName as NeighborhoodName
				,n.NbhoodSName as NeighborhoodSName
				,r.neighborhoodid as neighborhoodid
				,r.country as country
				,coalesce(ft.FoodType,'')  as food_type
				,ft.FoodTypeSName as FoodTypeSName
				,ft.FoodTypeID as FoodTypeID
				,moo.MinValue as moo_MinValue
				,(case when r.AcceptLargeParty = 0 then mxo2.MaxValue else mxo.MaxValue end) as mxo_MaxValue
				,r.MaxLargePartyID as MaxLargePartySize
				,r.AcceptLargeParty 'AcceptLargeParty'
				, Cast(mao.Days as int) as maoDays
				,(case when(PriceQuartileID=5) then 0 else PriceQuartileID end) as Price_Quartile_ID
				,er.Track as Track
				,cast((case when bl.RID is null then 0 else 1 end) as bit) CSSearchBlackList
				,coalesce(er.NetworkAddress,'') as NetworkAddress
				,coalesce(er.NewNetworkAddress,'') as NewNetworkAddress
				,fdo.OverrideRank as 'FeaturedDIPOverrideRank' 
				,fdo.OverrideDate as 'FeaturedDIPOverrideDate' 
				,(case when left(r.RSName, 4) = 'The ' then substring(r.RSName, 5, Len(r.RSName)-4) else r.RSName end) as RSNameSort
				,(case when left(r.RName, 4) = 'The ' then substring(r.RName, 5, Len(r.RName)-4) else r.RName end) as RNameSort	
				,r.Latitude
				,r.Longitude
				,r.DiningStyleID
				,n.MacroID as MacroID
				,(case when rcc.TotalSeatedStandardCovers IS NULL then 0 else rcc.TotalSeatedStandardCovers end) as TotalSeatedStandardCovers
				,coalesce(ri.ImageName,0) as RestaurantImage
				,(case when(coalesce(dffs.BlackListFlag, 0) = 1) then -1
					   when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0
					   else coalesce(dffs.totaldffs, 0) end) as totaldffs
				,(case when (coalesce(dffs.BlackListFlag, 0) = 1) then -1 
					   when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0 
					   else coalesce(AverageOverallRating, 0) end) as AverageOverallRating
				,case when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 1
					  else 0 end as RestaurantComingSoon			 		
				,r.Allotment as Allotment
				,ri.Thumbnail as RestaurantImageThumbnail 
				,ri.ThumbnailName
				,r.Address1  
				,r.Address2  
				,r.City  
				,r.[State]  
				,r.ZIP as ZIPCode  
				,isnull(rpr.Rank, 800000) as POPRank
				,case when (coalesce(vl.ValueID, 0) = 0) then 0 else 1 end as SuppressNextAvailButton
				,r.LimitedBooking
				,case when (coalesce(v2.ValueID, 0) = 0) then convert(bit,0) else convert(bit,1) end as ERBSearchIsBlacklisted
				,case when (coalesce(rss.SuppressionDays, 0) < 1) then convert(bit,0) else convert(bit,1) end as EarlyCutoff --Search Early Cut Off
				,case
				    when v4.ValueID is not null then convert(bit,1) 
					when r.RestaurantType = 'C' then convert(bit,1)
					else convert(bit,0)
				end as IsUmami
				,r.IsConnectFieldTest
				,CASE
					WHEN r.IsConnectFieldTest = 1 THEN 2		 -- OTAInstanceID, per the config file, associated with OTAvailability_FT
					WHEN r.RestaurantType = 'A' THEN 1			 -- OTDOTAInstnceID, per the config file,  for OTAvailability
					ELSE NULL								 -- Not a Connect RID
				 END AS OTAInstanceID
				,coalesce(rss.SuppressionDays, 0) as EarlyCutoffDays -- Number of days for Search Early Cut Off
				,CASE 
					WHEN COALESCE(v5.ValueID, 0) > 0 THEN 1
					ELSE 0
				END as FoodSpottingOptOut
	from		dbo.RestaurantVW r
	inner join	dbo.FoodTypes fts
	on			r.RID = fts.RID
	inner join	dbo.FoodType ft
	on			fts.FoodTypeID = ft.FoodTypeID
	and			fts.IsPrimary = 1
	and			ft.LanguageID = r.LanguageID
	inner join	dbo.NeighborhoodAVW n 
	on			n.neighborhoodid = r.neighborhoodid
	and			n.LanguageID = r.LanguageID
	inner join	dbo.ERBRestaurant er
	on			r.RID = er.RID
	inner join	dbo.MinOnlineOption moo
	on			r.MinOnlineOptionID = moo.MinOnlineOptionID
	inner join	dbo.MaxOnlineOption mxo
	on			r.MinCCOptionID = mxo.MaxOnlineOptionID
	inner join	dbo.MaxOnlineOption mxo2
	on			r.MinCCOptionID = mxo2.MaxOnlineOptionID
	inner join	dbo.MaxAdvanceOption mao
	on			r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
	left join	dbo.CacheSearchBlackList bl
	on			bl.RID = r.rid
	left join	dbo.FeaturedDIPOverride fdo 
	on			fdo.RID = r.RID
	left join	dbo.RestaurantCoverCounts rcc 
	on			rcc.RID = r.RID
	left join	dbo.RestaurantImage ri
	on			r.rid = ri.RID
	left join	dbo.DFFDailySummaryRIDStatsHolding dffs
	on			r.rid = dffs.webrid
	left join	dbo.RestaurantJustAdded rja
	on			r.rid = rja.rid
	left join   dbo.RestaurantPOPRankings   rpr
	on 			r.rid = rpr.rid
	--NextAvailBtn suppress blacklist
	left join	dbo.ValuelookupIDList vl
	on			r.RID = vl.ValueID and vl.LookupID = @SuppressNextAvailButtonValueMasterID 
	--ERB Search Blacklist
	left join	dbo.ValuelookupIDList v2
	on			r.RID = v2.ValueID and v2.LookupID = @ERBSearchBlacklistMasterID 
	--Early cutoff for search
	left join	dbo.RestaurantSuppression rss
	on			r.RID = rss.RID and rss.RestaurantSuppressionTypeId = 4  -- Search Early Cutoff type 
	left join	dbo.ValuelookupIDList v4
	on			r.RID = v4.ValueID and v4.LookupID = @UmamiWhitelistMasterID
	left join	dbo.ValueLookupIDList v5
	on			r.RID = v5.ValueID
	and			v5.LookupID = @FoodSpottingOptOut
	where		r.RestStateID != 4
	order by	metroareaid
				,RSNameSort
				,RNameSort
go

grant execute on [DNCacheRestaurantSearchList_v3] TO ExecuteOnlyRole
go
