

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllCountries]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllCountries]
GO


CREATE PROCEDURE dbo.Admin_CacheAllCountries
As
SET NOCOUNT ON
SELECT 	CountryID AS Abbreviation,
	CountryName AS CountryName,
	LanguageID,
	CASE WHEN (LEN(LTRIM(CountrySName)) = 0) THEN CountryName ELSE CountrySName END AS CountrySName,
	CASE WHEN (CountryCode IS NULL) THEN CountryName ELSE CountryName + ' +' + CountryCode END AS CountryPhone, 
	DateFormat,
	DateFormatDayIdx,
	DateFormatMonthIdx,
	DateFormatYearIdx,
	DateFormatDelimiter,
    MapLink
FROM CountryAVW
where CountryID != 'PR' -- remove the selection of country 'Puerto Rico'

ORDER BY coalesce(sortorder,99), CountrySName
GO

GRANT EXECUTE ON [Admin_CacheAllCountries] TO ExecuteOnlyRole

GO


