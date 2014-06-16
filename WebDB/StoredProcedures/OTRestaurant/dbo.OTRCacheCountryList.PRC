if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRCacheCountryList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRCacheCountryList]
GO


CREATE PROCEDURE dbo.OTRCacheCountryList
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT CountryID, 
	CountryName,
	CASE WHEN (LEN(LTRIM(CountrySName)) = 0) THEN CountryName ELSE CountrySName END AS CountrySName,
	Currency,
	DateFormat, 
	DateFormatDayIdx,
	DateFormatMonthIdx,
	DateFormatYearIdx,
	DateFormatValidationExp,
	DateFormatDelimiter,
	DisplayDateFormat
	AddressFormat,
	CurrencyType,
	CurrencySymbol
FROM      CountryVW c
ORDER BY CountrySName
GO

GRANT EXECUTE ON [OTRCacheCountryList] TO ExecuteOnlyRole

GO
