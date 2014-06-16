if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPromotedOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPromotedOffer]
go

--
-- Gets all Promoted RestaurantOffers that are associated with the given RID
-- 

create Procedure dbo.GetPromotedOffer
(
	@OfferID int
)
As

set transaction isolation level read committed

SELECT  ro.RID,  
   ros.StatusNameComment as StatusName,
   ro.OfferClassID,  
   ro.RestaurantOfferID AS OfferID,  
   ro.OfferVersion,  
   ro.OfferDescription,  -- todo : deprecate in favor for OfferTypeName  
   ro.OfferTypeID,  
   ro.StartDate AS OfferStartDate,  
   ro.EndDate AS OfferEndDate,  
   oc.IsInventoryManaged,  
   ro.CurrencyTypeID,  
   ro.OfferPrice,  
   ro.OfferStatusID,  
   ro.NoteToDiners,  
   ro.ResoCode,  
   ro.OfferName,  
   oc.IsPaidCreditCard,  
   coalesce(ro.DisplayOnOTWebsite, 0) AS DisplayOnOTWebsite,  
            ro.CreatedDtUTC,  
   ro.UpdatedDtUtc,
   ro.MinPartySize,
   ro.MaxPartySize,
   ro.ExcludesTax,
   ro.ExcludesService,
   ro.CreatedBy,
   ro.UpdatedBy
FROM  RestaurantOffer    ro  
  
INNER JOIN OfferClass oc  
ON   oc.OfferClassID    = ro.OfferClassID  
AND   oc.IsResoBased    = 1 -- Pick only the Reservationoffers  
AND   oc.OfferClassID    <> 2 --TopTable Passthrough offers are also ResoBased but need to be excluded here  
INNER JOIN  Restaurant     r  
ON    ro.RID      = r.RID  
	INNER JOIN
		dbo.RestaurantOfferStatus AS ros ON ro.OfferStatusID = ros.RestaurantOfferStatusID
	where
		ro.OfferClassID = 4	
		and ro.RestaurantOfferID = @OfferID
		
--offer type attributes 
SELECT [RestaurantOfferID]
      ,[OfferTypeAttributeKeyID]
      ,[ValueText]
      ,[ValueInt]
FROM [OfferTypeAttributeValue] ov
where ov.RestaurantOfferID = @OfferID

--slot times
SELECT [RestaurantOfferID]
      ,[DOW]
      ,[Date]
      ,[MaxInventory]
      ,[MinPartySize]
      ,[MaxPartySize]
      ,[SlotBits1]
      ,[SlotBits2]
      ,[SlotBits3]
  FROM [OfferDayLevelSchedule]
Where RestaurantOfferID = @OfferID

go


grant execute on [GetPromotedOffer] TO ExecuteOnlyRole

go
