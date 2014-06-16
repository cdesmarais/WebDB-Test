if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAllPromotedOfferTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAllPromotedOfferTypes]
go

--
-- Gets all Promoted RestaurantOffer types for a given country code
-- 

create Procedure dbo.GetAllPromotedOfferTypes
(
	@countryCode char(2) = null
)
As

if @countryCode is null
	select RestaurantOfferTypeLocalID,
			OfferTypeName,
			LanguageID,
			Rank,
			CountryID 
	from RestaurantOfferTypeLocal rot
	inner join OfferClassRestaurantOfferType oct
		on rot.RestaurantOfferTypeLocalID = oct.RestaurantOfferTypeID
	where oct.OfferClassID = 4 
		and rot.CountryID is null
Else
	select RestaurantOfferTypeLocalID,
			OfferTypeName,
			LanguageID,
			Rank,
			CountryID 
	from RestaurantOfferTypeLocal rot
	inner join OfferClassRestaurantOfferType oct
		on rot.RestaurantOfferTypeLocalID = oct.RestaurantOfferTypeID
	where oct.OfferClassID = 4 
		and rot.CountryID = @countryCode 
		
go

grant execute on [GetAllPromotedOfferTypes] TO ExecuteOnlyRole

go


