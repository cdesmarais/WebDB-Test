if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllStates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllStates]
GO


CREATE PROCEDURE dbo.Admin_CacheAllStates
As
SET NOCOUNT ON
SELECT 	CountryID AS Abbreviation,
	CountryName AS CountryName,
	LanguageID
FROM CountryAVW

ORDER BY CountryName
GO

GRANT EXECUTE ON [Admin_CacheAllStates] TO ExecuteOnlyRole

GO
