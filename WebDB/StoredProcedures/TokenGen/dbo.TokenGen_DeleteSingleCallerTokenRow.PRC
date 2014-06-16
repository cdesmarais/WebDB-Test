-- File: dbo.TokenGen_DeleteSingleCallerTokenRow.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_DeleteSingleCallerTokenRow]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_DeleteSingleCallerTokenRow
GO

CREATE PROCEDURE dbo.[TokenGen_DeleteSingleCallerTokenRow]
(
   @CallerId           INT,           -- not null
   @UserTokenTypeId    INT            -- not null
)
AS
BEGIN

			DELETE CallerToken
			WHERE CallerId = @CallerId AND UserTokenTypeId = @UserTokenTypeId

			RETURN @@ROWCOUNT
	
END
GO

GRANT EXECUTE ON [TokenGen_DeleteSingleCallerTokenRow] TO ExecuteOnlyRole
GO