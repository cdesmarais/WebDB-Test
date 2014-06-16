if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GenericPage_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GenericPage_Get]
GO

-- Returns list of all active email templates
CREATE PROCEDURE dbo.Admin_GenericPage_Get
 (
  @PageID int
 )
As

SELECT 
	[Name],
	[Content],
	LastUpdatedBy,
	UpdatedDate
from 		GenericPage gp
inner join 	GenericPageLocal gpl
on			gp.PageID = gpl.PageID
inner join	dbo.DBUserDistinctLanguageVW db 
on			db.languageid = gpl.LanguageID
where gp.PageID = 	@PageID
order by Name asc

GO

GRANT EXECUTE ON [Admin_GenericPage_Get] TO ExecuteOnlyRole

GO
