

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferTypes]
GO

--
-- Gets all the restaurant offer types 
-- 

create Procedure dbo.GetRestaurantOfferTypes

As

select	
	rot.RestaurantOfferTypeID
	,rot.OfferTypeName
	,rot.CountryID
	,rot.Rank
	,rot.LanguageID
from 	
	RestaurantOfferTypeAVW rot
inner join OfferClassRestaurantOfferType oct
	on rot.RestaurantOfferTypeID = oct.RestaurantOfferTypeID
where
	oct.OfferClassID = 1
order by 
	Rank Asc

GO

GRANT EXECUTE ON [GetRestaurantOfferTypes] TO ExecuteOnlyRole

GO


