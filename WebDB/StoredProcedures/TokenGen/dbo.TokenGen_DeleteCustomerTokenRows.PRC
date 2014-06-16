-- File: dbo.TokenGen_DeleteCustomerTokenRows.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_DeleteCustomerTokenRows]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_DeleteCustomerTokenRows
GO

CREATE PROCEDURE dbo.[TokenGen_DeleteCustomerTokenRows]
(
   @CustId             INT            -- not null
)
AS
BEGIN

			DELETE CustomerToken
			WHERE CustId = @CustId

			RETURN @@ROWCOUNT
	
END
GO

GRANT EXECUTE ON [TokenGen_DeleteCustomerTokenRows] TO ExecuteOnlyRole
GO