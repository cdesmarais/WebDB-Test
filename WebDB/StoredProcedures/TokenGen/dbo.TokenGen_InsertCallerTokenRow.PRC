-- File: dbo.TokenGen_InsertCallerTokenRow.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_InsertCallerTokenRow]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_InsertCallerTokenRow
GO

CREATE PROCEDURE dbo.[TokenGen_InsertCallerTokenRow]
(
   @CallerId           INT,           -- not null
   @UserTokenTypeId    INT,           -- not null
   @Hash               VARCHAR(32),   -- nullable
   @Salt               VARCHAR(32)    -- nullable
)
AS
BEGIN

			INSERT INTO CallerToken
			(CallerId, UserTokenTypeId, Hash, Salt)
			VALUES
			(@CallerId, @UserTokenTypeId, @Hash, @Salt)

			RETURN @@ROWCOUNT
	
END
GO

GRANT EXECUTE ON [TokenGen_InsertCallerTokenRow] TO ExecuteOnlyRole
GO