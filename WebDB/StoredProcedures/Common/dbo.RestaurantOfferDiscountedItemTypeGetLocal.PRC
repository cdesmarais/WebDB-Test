if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantOfferDiscountedItemTypeGetLocal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantOfferDiscountedItemTypeGetLocal]
GO
--Gets the menu types based on user language
CREATE PROCEDURE dbo.RestaurantOfferDiscountedItemTypeGetLocal
	@countryID varchar(2)
AS

select d.* from dbo.RestaurantOfferDiscountedItemTypeLocal d 
where d.CountryID = @countryID

GO

GRANT EXECUTE ON [RestaurantOfferDiscountedItemTypeGetLocal] TO ExecuteOnlyRole

GO
