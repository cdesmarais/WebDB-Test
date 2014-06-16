

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferBeverageScopes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferBeverageScopes]
GO

--
-- Gets all the restaurant offer beverage scope values
-- 

create Procedure dbo.GetRestaurantOfferBeverageScopes
as

select	
	RestaurantOfferBeverageScopeID
	,ScopeName
	,CountryID	
	,Rank
	,LanguageID
from	
	RestaurantOfferBeverageScopeAVW
order by 
	Rank Asc

GO

GRANT EXECUTE ON [GetRestaurantOfferBeverageScopes] TO ExecuteOnlyRole

GO


