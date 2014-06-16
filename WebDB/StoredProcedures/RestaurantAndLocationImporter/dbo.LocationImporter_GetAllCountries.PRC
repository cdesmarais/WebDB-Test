if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LocationImporter_GetAllCountries]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LocationImporter_GetAllCountries]
GO

CREATE Procedure dbo.LocationImporter_GetAllCountries

As
SET NOCOUNT ON
set transaction isolation level read uncommitted

select
	 c.CountryID
	,cl.CountryName
	,cl.CountrySName
	,c.CountryCode as DiallingCode
	,cl.DisplayDateFormat
	,c.DateFormat
	,c.IsDistanceInMiles
	,c.CurrencySymbol
	,c.CurrencyType
	,cl.AddressFormat
	,cl.LanguageID
	,c.MapLink
from Country c
join CountryLocal cl
on cl.CountryID = c.CountryID

GO

GRANT EXECUTE ON [LocationImporter_GetAllCountries] TO ExecuteOnlyRole

GO