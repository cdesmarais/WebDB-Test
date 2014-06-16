if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetAllEmailTemplates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetAllEmailTemplates]
GO

-- Returns list of all active email templates
CREATE PROCEDURE dbo.Admin_GetAllEmailTemplates
  
As

Declare @Languages AS int
Select @Languages = count(DISTINCT EmailTemplatedetails.LanguageID) from EmailTemplatedetails
inner join [Language] l
on			l.languageID = EmailTemplatedetails.languageID
where l.active = 1

SELECT distinct et.[EmailTemplateID],[TemplateName],[TemplateDescription], 
@Languages as Languages
from 		EmailTemplates et
inner join	[EmailTemplateDetails] etd
on			et.[EmailTemplateID] = etd.[EmailTemplateID]
inner join	dbo.DBUserDistinctLanguageVW db 
on			db.languageid = etd.LanguageID

where etd.Active = 1 and et.active = 1
	--these email templates are no longer configurable via charm (or no longer used)
	--36 --OTR-Account Reset
	--43 --OTR-Admin Followup Email
	--35 --OTR-Forgot Password
	--40 --OTR-New Account Welcome
	--41 --OTR-Request User Account
	--42 --OTR-User Request Rejection
	--27 --SEC - Multiple Resos From Same IP
	and et.EmailTemplateID not in (36,43,35,40,41,42,27)
order by TemplateName asc

GO

GRANT EXECUTE ON [Admin_GetAllEmailTemplates] TO ExecuteOnlyRole

GO