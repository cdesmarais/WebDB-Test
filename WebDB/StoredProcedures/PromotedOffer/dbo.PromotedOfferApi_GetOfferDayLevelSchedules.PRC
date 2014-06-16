if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromotedOfferApi_GetOfferDayLevelSchedule]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromotedOfferApi_GetOfferDayLevelSchedule]
GO

CREATE PROCEDURE dbo.PromotedOfferApi_GetOfferDayLevelSchedule
	@OfferId int
As

SET NOCOUNT ON
set transaction isolation level read uncommitted  

select   
	RestaurantOfferID,   
	DOW,     
	MaxInventory,   
	MinPartySize,   
	MaxPartySize,     
	SlotBits1,   
	SlotBits2,
	SlotBits3
from offerdaylevelschedule   
where RestaurantOfferID = @OfferId

GO

GRANT EXECUTE ON [PromotedOfferApi_GetOfferDayLevelSchedule] TO ExecuteOnlyRole

GO