if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantProfileDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantProfileDetails]
GO



--This proc fetches the data for the WebCache at specified WebcacheInterval
--This proc is called by StoredProcTab.cs in OT_MgrCache

CREATE Procedure [dbo].[DNCacheRestaurantProfileDetails]

As
SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT		r.RID
			,r.Email
			,r.Country
			,pq.PriceQuartileID AS Price
			,ft.FoodType as Cuisine
			,n.NbhoodName as NeighborhoodName
			,r.Chef
			,dc.DressCode AS DressCode
			,wo.WalkinOption AS Walkin
			,coalesce(ri.ImageName,0) as RestaurantImage
			,coalesce(rn.NetvisitID,0) as NetvisitID
			,r.HasCatering as Has_Catering
			,r.HasBanquet AS Has_Banquet
			,r.HasPrivateParty AS Has_Private_Party
			,BanquetPhone AS BanquetPhone
			,PrivatePartyPhone AS PrivatePartyPhone
			,PrivatePartyContact AS PrivatePartyContact
			,BanquetContact AS BanquetContact
			,ds.DiningStyle AS DiningStyle
			,r.TZID -- new MMC
			,pq.PriceQuartile as PriceDescription
			,rja.DateAdded AS InstallDate
			,coalesce(LargestCapacity,0) AS LargestCapacity
			,r.PrivatePartyEmail as PrivatePartyEmail
			,r.PrivateDiningMenu as PrivateDiningMenu
			,r.PublishPrivateDining as PublishPrivateDining
			,coalesce(ri.PrivateDiningThumbnail,'') as PrivateDiningThumbnail
			,t._offsetMI as GMTTZOffsetMin
			,ri.VideoEmbedCode
			,ri.VideoObjectId
			,rtr.TreatfulURL
			,CASE 
				WHEN COALESCE(vlid.ValueID, 0) > 0 THEN 1
				ELSE 0
			END as FoodSpottingOptOut
			,rs.RestaurantSurveyTypeID as SurveyTypeID
			,rs.Question as SurveyQuestion
			,rs.FeedbackYes as SurveyFeedbackYes
			,rs.FeedbackNo as SurveyFeedbackNo
			,rs.FeedbackInput as SurveyFeedbackInput
			,rs.Code as SurveyERBCode
			
FROM			RestaurantVW r

INNER JOIN		DiningStyleLocal ds
ON			r.DiningStyleID = ds.DiningStyleID 
and			ds.LanguageID = r.LanguageID
INNER JOIN		DressCodeLocal dc
ON			r.DressCodeID = dc.DressCodeID 
and			dc.LanguageID = r.LanguageID
INNER JOIN		WalkinOptionLocal wo
ON			r.WOID = wo.WOID
and			wo.LanguageID = r.LanguageID
INNER JOIN		ParkingLocal p
ON			r.ParkingID = p.ParkingID 
and			p.LanguageID = r.LanguageID
INNER JOIN		PriceQuartileAVW pq
ON			pq.PriceQuartileID = r.PriceQuartileID 
and			pq.LanguageID = r.LanguageID
and			pq.CountryID = r.Country
INNER JOIN		NeighborhoodAVW n 
ON			r.NeighborhoodID= n.NeighborhoodID 
AND			n.LanguageID = r.LanguageID
INNER JOIN 		TimezoneVW t
on			r.TZID = t.TZID
INNER JOIN		FoodTypes fts
ON			r.RID= fts.RID 
and			IsPrimary = 1
INNER JOIN		FoodType ft
ON			fts.FoodTypeID= ft.FoodTypeID 
and			ft.LanguageID = r.LanguageID
LEFT OUTER JOIN		RestaurantNetvisit rn
ON			r.rid = rn.RID
LEFT OUTER JOIN 	RestaurantImage ri
ON			r.rid = ri.RID
LEFT OUTER JOIN 	RestaurantJustAdded rja
ON			r.rid = rja.RID
LEFT OUTER JOIN 	RestaurantTreatful rtr
ON 			r.rid = rtr.RID
LEFT OUTER JOIN		ValueLookupIDList vlid
ON 			vlid.LookupID = 63  -- Blacklist - Foodspotting RIDs
AND 			r.rid = vlid.ValueID
left outer join		RestaurantSurveyRestaurants rsr
on			r.RID = rsr.RID
left outer join		RestaurantSurveysVW rs
on			rsr.RestaurantSurveyID = rs.RestaurantSurveyID
and			rs.Active = 1

WHERE		r.RestStateID <> 4

GO


GRANT EXECUTE ON [DNCacheRestaurantProfileDetails] TO ExecuteOnlyRole

GO
