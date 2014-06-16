

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferBeverageItems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferBeverageItems]
GO

--
-- Gets all the restaurant offer beverage item values 
-- 

create Procedure dbo.GetRestaurantOfferBeverageItems

As

select	
	RestaurantOfferBeverageDiscountItemID
	,DiscountItemName
	,CountryID
	,Rank
	,LanguageID
from 	
	RestaurantOfferBeverageDiscountItemAVW
order by 
	Rank Asc

GO

GRANT EXECUTE ON [GetRestaurantOfferBeverageItems] TO ExecuteOnlyRole

GO


