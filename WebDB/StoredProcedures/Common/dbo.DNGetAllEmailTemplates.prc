if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetAllEmailTemplates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetAllEmailTemplates]
GO

-- Returns list of all active email templates
CREATE PROCEDURE dbo.DNGetAllEmailTemplates
  
As
SET NOCOUNT ON
set transaction isolation level read uncommitted  


select e.EmailTemplateid,
	e.templatename,
	coalesce(d.emailfromdisplay,'') as emailfromdisplay,
	d.subject,
	d.emailbody,
	d.includeheader,
	d.includefooter,
	coalesce(hdr.elementdata,'') as theHeader,
	coalesce(ftr.elementdata,'') as  theFooter,
	d.LanguageID,
	d.isHTML
from EmailTemplates e 
inner join EmailTemplatedetails d 
		on d.EmailTemplateid = e.EmailTemplateid 
inner join EmailTemplateElements hdr 
		on hdr.emailelementtype = 'Header'
		and hdr.languageID = d.languageID
inner join EmailTemplateElements ftr 
		on ftr.emailelementtype = 'Footer'
		and ftr.languageID = d.languageID
where e.active = 1 and d.active=1 
order by templatename asc


GO

GRANT EXECUTE ON [DNGetAllEmailTemplates] TO ExecuteOnlyRole

GO
