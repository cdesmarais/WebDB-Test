

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferRequiredItems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferRequiredItems]
go

--
-- Get all required items Buy 1 Get 1 Offer type for the given language
-- 

create Procedure dbo.GetRestaurantOfferRequiredItems
As

select	
	*
from	
	RestaurantOfferRequiredItemAVW

go

GRANT EXECUTE ON [GetRestaurantOfferRequiredItems] TO ExecuteOnlyRole

go


