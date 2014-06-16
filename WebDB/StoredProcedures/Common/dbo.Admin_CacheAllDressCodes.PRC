if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllDressCodes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllDressCodes]
GO

CREATE procedure [dbo].[Admin_CacheAllDressCodes] 
AS
SET NOCOUNT ON

SELECT	DressCodeID,
	DressCode, 
	LanguageID
FROM	DressCodeAVW
Order by DressCodeID


GO

GRANT EXECUTE ON [Admin_CacheAllDressCodes] TO ExecuteOnlyRole
GO