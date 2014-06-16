if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromotedOfferApi_GetAllSpecialOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromotedOfferApi_GetAllSpecialOffers]
GO

CREATE PROCEDURE dbo.PromotedOfferApi_GetAllSpecialOffers
As

SET NOCOUNT ON
set transaction isolation level read uncommitted  


select 
   ro.RestaurantOfferID
  ,ro.OfferStatusID
  ,ro.RID
  ,ro.OfferName
  ,ro.StartDate
  ,ro.EndDate
  ,ro.Days
  ,ro.Times00_745
  ,ro.Times08_1545
  ,ro.Times16_2345
  ,ro.OfferDescription
  ,coalesce(ro.Priority, 0) as SortOrder
  ,r.LanguageID
from RestaurantOffer ro
join RestaurantVW r
on ro.Rid = r.Rid
where ro.OfferClassId = 1

GO

GRANT EXECUTE ON [PromotedOfferApi_GetAllSpecialOffers] TO ExecuteOnlyRole

GO