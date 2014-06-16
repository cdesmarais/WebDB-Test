if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheGenericPages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheGenericPages]
GO

-- Returns list of all active email templates
CREATE PROCEDURE dbo.DNCacheGenericPages
  
As

SELECT 
	gp.[PageID],
	[Name],
	[Content]
from 		GenericPage gp
inner join 	GenericPageLocal gpl
on			gp.PageID = gpl.PageID
inner join	dbo.DBUserDistinctLanguageVW db 
on			db.languageid = gpl.LanguageID
where active = 1
order by Name asc

GO

GRANT EXECUTE ON [DNCacheGenericPages] TO ExecuteOnlyRole

GO