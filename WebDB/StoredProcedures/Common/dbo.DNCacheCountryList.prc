if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheCountryList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheCountryList]
GO


CREATE PROCEDURE dbo.DNCacheCountryList
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT CountryID, 
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
	CASE WHEN (LEN(LTRIM(CountrySName)) = 0) THEN CountryName ELSE CountrySName END AS CountrySName,
	DisplayDateFormat
FROM      CountryVW
ORDER BY coalesce(sortorder,99), CountrySName
GO

GRANT EXECUTE ON [DNCacheCountryList] TO ExecuteOnlyRole

GO
