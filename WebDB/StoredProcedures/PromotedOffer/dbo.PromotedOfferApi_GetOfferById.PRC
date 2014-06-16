if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromotedOfferApi_GetOfferById]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromotedOfferApi_GetOfferById]
GO

CREATE PROCEDURE dbo.PromotedOfferApi_GetOfferById
	@OfferId int
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
   ,rotv.OfferTypeName
   ,rotv.Rank
   ,ro.DisplayOnOTWebsite
   ,ro.CreatedDtUTC
   ,coalesce(ro.UpdatedDtUtc, ro.CreatedDtUTC) as UpdatedDtUtc
   ,ro.ExcludesService
   ,ro.ExcludesTax
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
	AND oc.IsResoBased = 1 
	AND oc.OfferClassID <> 2 
inner join RestaurantVW r 
	on ro.RID = r.RID 
inner join RestaurantOfferTypeAVW rotv 
	on ro.OfferTypeID = rotv.RestaurantOfferTypeID  
	and r.LanguageID = rotv.LanguageID
inner join TimezoneVW   tz
  on r.TZID = tz.TZID
left join ValuelookupIDList vRID_Blacklist
  on r.RID = vRID_Blacklist.ValueID and vRID_Blacklist.LookupID = @RID_BlacklistOffer_ValueMasterID
where
r.RestStateID  != 4
and coalesce(vRID_Blacklist.ValueID, 0) = 0
and ro.RestaurantOfferID = @OfferId

GO

GRANT EXECUTE ON [PromotedOfferApi_GetOfferById] TO ExecuteOnlyRole

GO