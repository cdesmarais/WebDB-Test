if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_EmailTemplates_GetLang]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_EmailTemplates_GetLang]
GO

CREATE Procedure dbo.Admin_EmailTemplates_GetLang
 (
  @ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select LanguageID from EmailTemplateDetails where EmailTemplateID = @ID


GO


GRANT EXECUTE ON [Admin_EmailTemplates_GetLang] TO ExecuteOnlyRole

GO

