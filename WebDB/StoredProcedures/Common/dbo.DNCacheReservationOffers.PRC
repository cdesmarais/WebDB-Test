
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheReservationOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheReservationOffers]
GO



CREATE PROCEDURE dbo.DNCacheReservationOffers
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--ValueLookupMasterID for BlackListed Restaurants to suppress offers.
declare @RID_BlacklistOffer_ValueMasterID int = 74

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
	
Select		 ro.RID
			,ro.OfferClassID
			,ro.OfferID
			,ro.OfferVersion	as OfferVersionID
			,ro.OfferDescription
			,ro.OfferTypeID
			,ro.OfferStartDate
			,ro.OfferEndDate	
			,convert(bit, oc.IsInventoryManaged) as IsInventoryManaged
			,ro.CurrencyTypeID
			,ro.OfferPrice
			,ro.NoteToDiners
			,ro.ResoCode
			,r.RName			as RName
			,r.RSName			as RSName
			,(case when left(r.RName, 4) = 'The ' then substring(r.RName, 5, Len(r.RName)-4) else r.RName end) as RNameSort	
			,(case when left(r.RSName, 4) = 'The ' then substring(r.RSName, 5, Len(r.RSName)-4) else r.RSName end) as RSNameSort
			,r.NeighborhoodID	as NeighborhoodID
			,n.NBHoodName		as NeighborhoodName
			,n.NBHoodSName		as NeighborhoodSName
			,n.MacroID			as MacroID
			,n.MetroAreaID		as MetroAreaID
			,ft.FoodTypeID		as FoodTypeID
			,coalesce(ft.FoodType,'')	as FoodTypeName
			,ft.FoodTypeSName	as FoodTypeSName
			,r.PriceQuartileID	as PriceQuartileID
			,r.Country			as CountryID
			,(case when rcc.TotalSeatedStandardCovers IS NULL then 0 else rcc.TotalSeatedStandardCovers end) as TotalSeatedStandardCovers
			,coalesce(ri.ImageName,0) as RestaurantImage
			,coalesce(ri.Thumbnail, ri.ThumbnailName) 		as RestaurantImageThumbnail 
			,ri.ThumbnailName	as RestaurantImageThumbnailName
			,(case when(coalesce(dffs.BlackListFlag, 0) = 1) then -1
				   when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0
				   else coalesce(dffs.totaldffs, 0) end) as totaldffs
			,(case when (coalesce(dffs.BlackListFlag, 0) = 1) then -1 
				   when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0 
				   else coalesce(AverageOverallRating, 0) end) as AverageOverallRating
			,case when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 1
				  else 0 end as RestaurantComingSoon
		    ,ro.OfferName
		    ,ro.OfferTypeName
			,ro.Rank           
            ,ro.DisplayOnOTWebsite	            
            ,ro.CreatedDtUTC
            ,coalesce(ro.UpdatedDtUtc, ro.CreatedDtUTC)  as  UpdatedDtUtc
            ,ro.ExcludesService
            ,ro.ExcludesTax
            ,ro.MinPartySize
            ,ro.MaxPartySize
			,ro.Days
FROM		ReservationOfferVW	ro
INNER JOIN	OfferClass			oc
ON			ro.OfferClassID		= oc.OfferClassID
INNER JOIN	RestaurantVW		r
ON			ro.RID				= r.RID
INNER JOIN	TimezoneVW			tz
ON			r.TZID				= tz.TZID
inner join	NeighborhoodVW		n
on			r.NeighborhoodID = n.NeighborhoodID
inner join	FoodTypes fts
on			r.RID = fts.RID
inner join	FoodType ft
on			fts.FoodTypeID = ft.FoodTypeID
and			fts.IsPrimary = 1
and			ft.LanguageID = r.LanguageID
left join	RestaurantCoverCounts rcc 
on			rcc.RID = r.RID
left join	RestaurantImage ri
on			r.rid = ri.RID
left join	DFFDailySummaryRIDStatsHolding dffs
on			r.rid = dffs.webrid
left join	RestaurantJustAdded rja
on			r.rid = rja.rid
left join	ValuelookupIDList vRID_Blacklist
on			r.RID = vRID_Blacklist.ValueID and vRID_Blacklist.LookupID = @RID_BlacklistOffer_ValueMasterID

WHERE		ro.OfferStatusID	= 1 -- Pick active offers only
AND			ro.OfferEndDate		>= CAST(tz.currentLocalTime AS DATE) -- Filter out expired offers
and			r.RestStateID		!= 4
and			coalesce(vRID_Blacklist.ValueID, 0) = 0

AND	NOT		(
			 -- filter out promotional offers where ShowNow disabled and offer not yet active
			 ro.OfferClassID			= 4							-- promo offer
AND			 ro.DisplayOnOTWebsite		= 0							-- ShowNow disabled
AND			 ro.OfferStartDate			> CAST(tz.currentLocalTime AS DATE)		-- offer not yet in effect
			)

GO

GRANT EXECUTE ON [DNCacheReservationOffers] TO ExecuteOnlyRole

GO