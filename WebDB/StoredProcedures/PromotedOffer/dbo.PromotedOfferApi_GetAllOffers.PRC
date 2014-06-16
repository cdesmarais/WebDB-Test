if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromotedOfferApi_GetAllOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromotedOfferApi_GetAllOffers]
GO

CREATE PROCEDURE dbo.PromotedOfferApi_GetAllOffers
As

SET NOCOUNT ON
set transaction isolation level read uncommitted  

--ValueLookupMasterID for BlackListed Restaurants to suppress offers.  
declare @RID_BlacklistOffer_ValueMasterID int = 74  

select
    ro.RID
   ,ro.OfferClassID
   ,ro.RestaurantOfferID as OfferID
   ,ro.OfferVersion as OfferVersionID
   ,ro.OfferDescription
   ,ro.OfferTypeID
   ,ro.StartDate as OfferStartDate
   ,ro.EndDate as OfferEndDate
   ,ro.CurrencyTypeID
   ,ro.OfferPrice
   ,ro.NoteToDiners
   ,ro.ResoCode
   ,ro.OfferName
   ,rotl.OfferTypeName
   ,rotl.Rank
   ,ro.DisplayOnOTWebsite
   ,ro.CreatedDtUTC
   ,coalesce(ro.UpdatedDtUtc, ro.CreatedDtUTC) as UpdatedDtUtc
   ,isnull(ro.ExcludesService, 0) as ExcludesService
   ,isnull(ro.ExcludesTax, 0) as ExcludesTax
   ,ro.MinPartySize
   ,ro.MaxPartySize
   ,ro.Days
   ,r.Country
   ,tz.TZName
   ,ro.OfferStatusId
   ,r.DomainID
   ,ro.CreatedBy
   ,ro.UpdatedBy
from RestaurantOffer ro 
inner join OfferClass oc 
	on oc.OfferClassID = ro.OfferClassID 
	AND oc.OfferClassID <> 2 
inner join RestaurantVW r 
	on ro.RID = r.RID 
inner join RestaurantOfferType rotv 
	on ro.OfferTypeID = rotv.RestaurantOfferTypeID
inner join RestaurantOfferTypeLocal rotl
    on rotv.RestaurantOfferTypeID = rotl.RestaurantOfferTypeLocalID
	and rotl.LanguageID = r.LanguageID
inner join TimezoneVW   tz
  on r.TZID = tz.TZID
left join ValuelookupIDList vRID_Blacklist
  on r.RID = vRID_Blacklist.ValueID and vRID_Blacklist.LookupID = @RID_BlacklistOffer_ValueMasterID
where
r.RestStateID  != 4
and coalesce(vRID_Blacklist.ValueID, 0) = 0


GO

GRANT EXECUTE ON [PromotedOfferApi_GetAllOffers] TO ExecuteOnlyRole

GO