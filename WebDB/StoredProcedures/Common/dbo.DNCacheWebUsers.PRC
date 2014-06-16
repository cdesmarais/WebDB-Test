if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheWebUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheWebUsers]
GO

CREATE Procedure dbo.DNCacheWebUsers
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 	DBUserID, 
		DBUser, 
		LanguageID, 
		DomainID, 
		OPLanguageID 
FROM 	[DBUser]
WHERE 	[DBUser] 
LIKE 	'WebUser%'

GO

GRANT EXECUTE ON [DNCacheWebUsers] TO ExecuteOnlyRole

GO

