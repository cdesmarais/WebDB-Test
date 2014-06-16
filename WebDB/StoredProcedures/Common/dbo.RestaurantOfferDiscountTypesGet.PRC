if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantOfferDiscountTypesGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantOfferDiscountTypesGet]
GO
--Gets the menu types based on user language
CREATE PROCEDURE dbo.RestaurantOfferDiscountTypesGet
AS

select m.DiscountTypeID, m.DiscountName, m.IsDefault 
from dbo.RestaurantOfferDiscountType m

GO

GRANT EXECUTE ON [RestaurantOfferDiscountTypesGet] TO ExecuteOnlyRole

GO


