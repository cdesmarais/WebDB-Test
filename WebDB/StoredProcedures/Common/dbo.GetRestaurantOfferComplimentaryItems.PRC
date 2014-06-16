

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantComplimentaryItems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantComplimentaryItems]
GO

--
-- Gets all the restaurant offer complimentary item values 
-- 

create Procedure dbo.GetRestaurantComplimentaryItems
As

select	
	RestaurantOfferComplimentaryItemID
	,ItemName
	,CountryID
	,Rank
	,LanguageID
from	
	RestaurantOfferComplimentaryItemAVW
order by 
	Rank Asc


GO

GRANT EXECUTE ON [GetRestaurantComplimentaryItems] TO ExecuteOnlyRole

GO

