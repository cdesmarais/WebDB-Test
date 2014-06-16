if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_EmailTemplates_GetAllLang]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_EmailTemplates_GetAllLang]
GO

CREATE Procedure dbo.Admin_EmailTemplates_GetAllLang
 (
  @ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select	l.LanguageID+20 DSN_ID, 
	substring(l.[languageRegionDesc], 0, charindex(' - ', l.[languageRegionDesc])) DomainLanguage,
	'' Logo
from	EmailTemplateDetails e
inner join Language l
on	e.LanguageID = l.LanguageID
where	e.EmailTemplateID = @ID
	AND	l.Active = 1

GO


GRANT EXECUTE ON [Admin_EmailTemplates_GetAllLang] TO ExecuteOnlyRole

GO