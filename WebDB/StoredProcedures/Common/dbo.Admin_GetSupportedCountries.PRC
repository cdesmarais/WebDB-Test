if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetSupportedCountries]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetSupportedCountries]
GO


CREATE PROCEDURE dbo.Admin_GetSupportedCountries
As
SET NOCOUNT ON

SELECT DISTINCT CountryVW.CountryID, 
	CountryName, 
	CountryCode, 
	(countryname + ' +' + countrycode) as CountryPhone, 
	Currency,
	(CountryName + ' - ' + Currency) as CountryCurrency,
	Delivery,
	MapLink,
	DateFormat, 
	DateFormatDayIdx,
	DateFormatMonthIdx,
	DateFormatYearIdx,
	DateFormatValidationExp,
	DateFormatDelimiter,
	PriceDescription,
	AddressFormat,
	coalesce(sortorder,99)
FROM      CountryVW
INNER JOIN [MetroAreaVW] ON [CountryVW].[CountryID] = [MetroAreaVW].[CountryID]
ORDER BY coalesce(sortorder,99), countryname

GO

GRANT EXECUTE ON [Admin_GetSupportedCountries] TO ExecuteOnlyRole

GO
