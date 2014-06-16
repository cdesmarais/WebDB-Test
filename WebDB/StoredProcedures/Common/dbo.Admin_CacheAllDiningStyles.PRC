if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllDiningStyles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllDiningStyles]
GO

CREATE procedure [dbo].[Admin_CacheAllDiningStyles] 
AS
SET NOCOUNT ON

SELECT	DiningStyleID,
	DiningStyle, 
	LanguageID
FROM	DiningStyleAVW
Order by DiningStyleID


GO

GRANT EXECUTE ON [Admin_CacheAllDiningStyles] TO ExecuteOnlyRole
GO