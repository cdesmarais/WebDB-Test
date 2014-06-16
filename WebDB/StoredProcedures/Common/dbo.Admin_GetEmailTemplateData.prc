if exists (select * from dbo.sysobjects where ID = object_ID(N'[dbo].[Admin_GetEmailTemplateData]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetEmailTemplateData]
GO

-- Returns list of specific email template
CREATE PROCEDURE dbo.Admin_GetEmailTemplateData
(
	@theEmailTemplateID int
) 
As

--************************
--** Retrieve the LanguageID based on the DB connection
--** Error Out if no language Found
--************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

--*************************
--** CVS: Reformated file. Changed query to use inner joins rather than sub select
--*************************
select e.EmailTemplateID,
	e.templatename,
	e.templatedescription,
	d.templatedetailsID,
	coalesce(d.emailfromdisplay,'') as emailfromdisplay,
	d.subject,
	d.emailbody,
	d.updatedby,
	d.updatedatets,
	d.includeheader,
	d.includefooter, 
	coalesce(hdr.elementdata,'') as theHeader,
	coalesce(ftr.elementdata,'') as  theFooter,
	(Select count(*) from EmailTemplatedetails where EmailTemplateID = e.EmailTemplateID and Active = 1) as Languages
from EmailTemplates e 
inner join EmailTemplatedetails d 
		on d.EmailTemplateID = e.EmailTemplateID 
		and d.LanguageID = @LanguageID
inner join EmailTemplateElements hdr 
		on hdr.emailElementType = 'Header'
		and hdr.languageID = d.languageID
inner join EmailTemplateElements ftr 
		on ftr.emailElementType = 'Footer'
		and ftr.languageID = d.languageID
where	e.EmailTemplateID = @theEmailTemplateID 
	and e.active = 1
	and d.active=1 

GO


GRANT EXECUTE ON [Admin_GetEmailTemplateData] TO ExecuteOnlyRole

GO
