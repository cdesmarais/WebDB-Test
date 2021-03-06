-- File: dbo.TokenGen_DeleteCallerTokenRows.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_DeleteCallerTokenRows]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_DeleteCallerTokenRows
GO

CREATE PROCEDURE dbo.[TokenGen_DeleteCallerTokenRows]
(
   @CallerId           INT            -- not null
)
AS
BEGIN

			DELETE CallerToken
			WHERE CallerId = @CallerId

			RETURN @@ROWCOUNT
	
END
GO

GRANT EXECUTE ON [TokenGen_DeleteCallerTokenRows] TO ExecuteOnlyRole
GO