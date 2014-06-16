-- File: dbo.TokenGen_DeleteSingleCustomerTokenRow.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_DeleteSingleCustomerTokenRow]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_DeleteSingleCustomerTokenRow
GO

CREATE PROCEDURE dbo.[TokenGen_DeleteSingleCustomerTokenRow]
(
   @CustId             INT,           -- not null
   @UserTokenTypeId    INT            -- not null
)
AS
BEGIN

			DELETE CustomerToken
			WHERE CustId = @CustId AND UserTokenTypeId = @UserTokenTypeId

			RETURN @@ROWCOUNT
	
END
GO

GRANT EXECUTE ON [TokenGen_DeleteSingleCustomerTokenRow] TO ExecuteOnlyRole
GO