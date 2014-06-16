if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CountryToLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CountryToLanguage]
GO


CREATE Procedure dbo.Admin_CountryToLanguage
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 	DISTINCT	
		[CountryLanguages].CountryID, 
		[CountryLanguages].LanguageID,
		LanguageCode, 
		LanguageRegionDesc
FROM 		[CountryLanguages]
INNER JOIN 	country c
ON 		[CountryLanguages].CountryID = c.CountryID
INNER JOIN 	[Language] 
ON 		[CountryLanguages].LanguageID = [Language].LanguageID

ORDER 	BY [CountryLanguages].CountryID

GO

GRANT EXECUTE ON [Admin_CountryToLanguage] TO ExecuteOnlyRole
GO  

