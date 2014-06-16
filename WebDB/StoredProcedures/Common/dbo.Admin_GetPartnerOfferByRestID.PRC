if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetPartnerOfferByRestID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetPartnerOfferByRestID]
GO

create procedure [dbo].[Admin_GetPartnerOfferByRestID]
(
	@RestaurantID int
)
as 

/**************************************************************************************
Purpose: To get the Restaurant Name and status of Partner Product offer for Restaurant.
***************************************************************************************/
select   
	r.RName as RestaurantName  
	,r.AcceptFlower as [Flower Petal]  
	,r.AcceptGift as [Red Envelope]  
	,r.LimitedBooking as [Restricted by Restaurant Blocked List]	
	,case  
		when vl.ValueId > 0 Then 1
		else 0
	end	as [Restaurant Marketing Email Opted In for Rest Ref]
	,case  
		when vl2.ValueId > 0 Then 1
		else 0
	end	as [Limo Service Suppression]
	,case  
		when v3.ValueId > 0 Then 1
		else 0
	end	as [Private Dining Email Link Opted Out for Restref]
	,r.AdWordsID
	,r.AdWordsValue
	,cp.[Enabled] as [Parking Enabled] 
	,case  
		when vl4.ValueId > 0 Then 0
		else 1
	end	as [Show POP as Last Offer]
	,case  
		when vl5.ValueId > 0 Then 1
		else 0
	end	as [AMEX Suppression]
	,case
		--if there's a value here, then the rest is blacklisted in FoodSpotting  
		when vFood.ValueId > 0 Then 1
		else 0
	end	as [FoodSpottingSuppressed]
	,case
		--if there's a value here, then the rest is blacklisted in FoodSpotting  
		when vVVOffers.ValueId > 0 Then 1
		else 0
	end	as [VVSuppressed]	
  , ro.OfferClassID
    , ro.OfferStatusID
    , ro.RestaurantOfferID
	, ro.ThirdPartyOfferID
	,r.ShowFaceBookLikeBox
	,r.ShowThirdPartyMenu	
  , case 
      when vHidePromotedOffersOnRestRef.ValueId is not null then 1 
      else 0 
  end as [HidePromotedOffersOnRestRef]
  ,rt.TreatfulRID
  ,rt.TreatfulURL 
  ,case 
	when BlackListPWR.RID is not null then 1
	else 0
   end as [IsBlackListed]
    --if there's a entry for the rest here, then the rest is excluded from Partner feed
  ,case   
	when PartnerFeedEL.RID is not null then 1  
	else 0  
   end as [IsExcludedFromPartnerFeed] 
FROM			RestaurantVW	r  
left outer join ValueLookupIdList vl
on 				r.RID = vl.ValueId 
and				vl.LookupId = 3 /* Lookup Id 3 corresponds to key REST_REF_EMAIL_OPTIN from ValueLookupMaster table */
LEFT OUTER JOIN	ValueLookupIdList vl2
ON				r.RID = vl2.ValueID
AND				vl2.LookupID = 23 /*LookupID 23 used for LIMO_SUPPRESSED_BY_RID from ValueLookupMaster */
LEFT OUTER JOIN	ValueLookupIdList v3
ON				r.RID = v3.ValueID
AND				v3.LookupID = 40 /*LookupID 40 used for REST_REF_PD_EMAIL_MESSAGE_OPTOUT from ValueLookupMaster */
left outer join RestaurantCentralParking cp
ON				cp.RID = @RestaurantID
left outer join ValueLookupIdList vl4   /* Lookup ID 51 used for (DO NOT) SHOW_POP_AS_LAST_OFFER from ValueLookupMaster */
on 				r.RID = vl4.ValueId 
and				vl4.LookupId = 51
LEFT OUTER JOIN	ValueLookupIdList vl5
ON				r.RID = vl5.ValueID
AND				vl5.LookupID = 58 /*LookupID 58 used for AMEX_PARTNER_RID_BLACKLIST from ValueLookupMaster */
LEFT OUTER JOIN	ValueLookupIdList vFood
ON				r.RID = vFood.ValueID
AND				vFood.LookupID = 63 /*FoodSpotting blacklist */
LEFT OUTER JOIN	ValueLookupIdList vVVOffers
ON				r.RID = vVVOffers.ValueID
AND				vVVOffers.LookupID = 74 /*VV Offers blacklist */
LEFT OUTER JOIN RestaurantOffer ro
ON				r.RID = ro.RID
LEFT OUTER JOIN ValueLookupIdList vHidePromotedOffersOnRestRef
ON        r.RID = vHidePromotedOffersOnRestRef.ValueId
AND       vHidePromotedOffersOnRestRef.LookupId = 86
LEFT OUTER JOIN RestaurantTreatful rt
ON				r.RID = rt.RID
LEFT OUTER JOIN BlackListPromoWeekRestaurants BlackListPWR
ON				r.RID = BlackListPWR.RID
LEFT OUTER JOIN PartnerFeedExclusionList PartnerFeedEL  
ON    r.RID = PartnerFeedEL.RID

WHERE			r.RID = @RestaurantID  
GO

GRANT EXECUTE ON dbo.[Admin_GetPartnerOfferByRestID] TO ExecuteOnlyRole
go

GRANT EXECUTE ON dbo.[Admin_GetPartnerOfferByRestID] TO WebUserUS
go
