if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantOfferMenuTypesGetLocal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantOfferMenuTypesGetLocal]
GO
--Gets the menu types based on user language
CREATE PROCEDURE dbo.RestaurantOfferMenuTypesGetLocal
	@countryID varchar(2)
AS

select m.MenuTypeID, m.MenuName, m.IsDefault, m.LanguageID, m.Rank, m.CountryID 
from dbo.RestaurantOfferMenuTypeLocal m
where m.CountryID = @countryID

GO

GRANT EXECUTE ON [RestaurantOfferMenuTypesGetLocal] TO ExecuteOnlyRole

GO



