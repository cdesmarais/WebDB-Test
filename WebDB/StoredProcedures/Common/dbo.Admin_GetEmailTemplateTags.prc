if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetEmailTemplateTags]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetEmailTemplateTags]
GO

-- Returns list of specific email template
CREATE PROCEDURE dbo.Admin_GetEmailTemplateTags
(
	@theEmailTemplateID int
) 
As

SELECT e.templatename
	,c.tagname
	,coalesce(c.tagtestreplacedata,'') as tagtestreplacedata
	,NewLineBefore
	,NewLineAfter
	,c.tagid
FROM emailtemplatetagscatalog c
INNER JOIN emailtemplatetags t
ON c.TagID = t.TagID
INNER JOIN emailtemplates e
ON t.EmailTemplateID = e.EmailTemplateID
WHERE e.emailtemplateid = @theEmailTemplateID
ORDER BY e.emailtemplateid ASC

GO

GRANT EXECUTE ON [Admin_GetEmailTemplateTags] TO ExecuteOnlyRole

GO
