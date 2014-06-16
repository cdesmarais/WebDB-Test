

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferDiscountedItems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferDiscountedItems]
go

--
-- Get all Discount items Buy 1 Get 1 Offer type for the given language
-- 

create Procedure dbo.GetRestaurantOfferDiscountedItems
As

select	
	*
from	
	RestaurantOfferDiscountedItemAVW

go

GRANT EXECUTE ON [GetRestaurantOfferDiscountedItems] TO ExecuteOnlyRole

go


