if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromotedOfferApi_GetAllOfferTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromotedOfferApi_GetAllOfferTypes]
go

--
-- Gets all Offer types
-- 

create Procedure dbo.PromotedOfferApi_GetAllOfferTypes
As

set nocount on
set transaction isolation level read uncommitted  

select 
	RestaurantOfferTypeLocalID,
	OfferTypeName,
	LanguageID,
	Rank,
	CountryID 
from RestaurantOfferTypeLocal rot
inner join OfferClassRestaurantOfferType oct
	on rot.RestaurantOfferTypeLocalID = oct.RestaurantOfferTypeID
where oct.OfferClassID = 4
and CountryID is not null

go

grant execute on [PromotedOfferApi_GetAllOfferTypes] TO ExecuteOnlyRole

go


