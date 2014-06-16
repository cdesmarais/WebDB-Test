if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetAllEmailTemplateTagData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetAllEmailTemplateTagData]
GO

-- Returns list of all active email templates
CREATE PROCEDURE dbo.DNGetAllEmailTemplateTagData
  
As
SET NOCOUNT ON
set transaction isolation level read uncommitted  


select c.tagid,
	e.EmailTemplateid,
	e.templatename,
	c.tagname,
	c.newlinebefore,
	c.newlineafter 
from EmailTemplateTagsCatalog c
inner join	EmailTemplatetags t
		on	c.tagid = t.tagid
inner join	EmailTemplates e
	on e.EmailTemplateid = t.EmailTemplateid 
order by e.EmailTemplateid asc

GO

GRANT EXECUTE ON [DNGetAllEmailTemplateTagData] TO ExecuteOnlyRole

GO
