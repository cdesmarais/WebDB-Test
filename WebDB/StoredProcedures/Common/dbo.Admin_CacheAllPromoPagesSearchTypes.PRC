if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllPromoPagesSearchTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllPromoPagesSearchTypes]
GO

CREATE procedure [dbo].[Admin_CacheAllPromoPagesSearchTypes]

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT	SearchTypeID,
	SearchTypeName
FROM	PromoPagesSearchType
Order by SearchTypeName


GO

GRANT EXECUTE ON [Admin_CacheAllPromoPagesSearchTypes] TO ExecuteOnlyRole
GO