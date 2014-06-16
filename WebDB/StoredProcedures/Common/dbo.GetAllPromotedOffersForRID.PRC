if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAllPromotedOffersForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAllPromotedOffersForRID]
go

--
-- Gets all Promoted RestaurantOffers that are associated with the given RID
-- 

create Procedure dbo.GetAllPromotedOffersForRID
(
	@RID int
)
As

set transaction isolation level read committed

DECLARE @StatusName nvarchar(32)

--get text for expired status
SELECT @StatusName = StatusNameComment FROM RestaurantOfferStatus
WHERE RestaurantOfferStatusID = 3

SELECT  ro.RID,  
   StatusName = case 
					when  CAST(tvw.currentLocalTime AS DATE) > ro.EndDate 
						then @StatusName --expired
					else
						ros.StatusNameComment 
				end,
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
   OfferStatusID = case 
					when  ro.OfferStatusID = 1 AND  
							CAST(tvw.currentLocalTime AS DATE) > ro.EndDate 
						then 3 --mark as expired 
					else
						ro.OfferStatusID
				end,
   ro.NoteToDiners,  
   ro.ResoCode,  
   ro.OfferName,  
   rotv.OfferTypeName,  
   rotv.Rank,  
   oc.IsPaidCreditCard,  
   coalesce(ro.DisplayOnOTWebsite, 0) AS DisplayOnOTWebsite,  
            ro.CreatedDtUTC,  
   ro.UpdatedDtUtc,
   tvw.currentLocalTime as RestaurantLocalDt
FROM  RestaurantOffer    ro  
INNER JOIN RestaurantVW rvw
ON ro.RID = rvw.RID
INNER JOIN TimezoneVW tvw
ON tvw.TZID = rvw.TZID
INNER JOIN OfferClass oc  
ON   oc.OfferClassID    = ro.OfferClassID  
AND   oc.IsResoBased    = 1 -- Pick only the Reservationoffers  
AND   oc.OfferClassID    <> 2 --TopTable Passthrough offers are also ResoBased but need to be excluded here  
INNER JOIN  Restaurant     r  
ON    ro.RID      = r.RID  
INNER JOIN RestaurantOfferTypeVW   rotv  
ON   ro.OfferTypeID     = rotv.RestaurantOfferTypeID  
	INNER JOIN
		dbo.RestaurantOfferStatus AS ros ON ro.OfferStatusID = ros.RestaurantOfferStatusID
		and ro.OfferStatusID in (1,3) -- only show Active and Expired
where
	ro.RID = @RID
	and ro.OfferClassID = 4	
order by OfferStatusID asc, ro.RestaurantOfferID desc

go

grant execute on [GetAllPromotedOffersForRID] TO ExecuteOnlyRole

go
