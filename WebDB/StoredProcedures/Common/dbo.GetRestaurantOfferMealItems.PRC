

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferMealItems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferMealItems]
GO

--
-- Gets all the restaurant offer meal item values for the given language
-- 

create Procedure dbo.GetRestaurantOfferMealItems
As

select	
	RestaurantOfferMealDiscountItemID
	,DiscountItemName
	,CountryID
	,Rank
	,LanguageID
from	
	RestaurantOfferMealDiscountItemAVW
order by 
	Rank Asc

GO

GRANT EXECUTE ON [GetRestaurantOfferMealItems] TO ExecuteOnlyRole

GO

