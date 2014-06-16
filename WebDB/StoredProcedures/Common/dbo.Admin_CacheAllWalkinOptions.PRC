if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllWalkinOptions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllWalkinOptions]
GO

CREATE procedure [dbo].[Admin_CacheAllWalkinOptions] 
AS
SET NOCOUNT ON

SELECT	WOID,
	WalkinOption, 
	LanguageID
FROM	WalkinOptionAVW
Order by WOID


GO

GRANT EXECUTE ON [Admin_CacheAllWalkinOptions] TO ExecuteOnlyRole
GO