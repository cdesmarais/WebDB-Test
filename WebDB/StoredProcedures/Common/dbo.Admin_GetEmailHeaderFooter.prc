if exists (select * from dbo.sysobjects where ID = object_ID(N'[dbo].[Admin_GetEmailHeaderFooter]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetEmailHeaderFooter]
GO

-- Returns list of specific email template
CREATE PROCEDURE dbo.Admin_GetEmailHeaderFooter
As

--************************
--** Retrieve the LanguageID based on the DB connection
--** Error Out if no language Found
--************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

Declare @Languages AS int
Select @Languages = count(DISTINCT LanguageID) from emailTemplateElements


select emailElementID,
	coalesce(ElementData,'') as ElementData,
	emailElementtype,
	@Languages as Languages
from emailTemplateElements
where LanguageID = @LanguageID

GO

GRANT EXECUTE ON [Admin_GetEmailHeaderFooter] TO ExecuteOnlyRole

GO
