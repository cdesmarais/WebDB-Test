-- File: dbo.TokenGen_SelectCustomerWithTokenRows.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_SelectCustomerWithTokenRows]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_SelectCustomerWithTokenRows
GO

CREATE PROCEDURE dbo.[TokenGen_SelectCustomerWithTokenRows]
(
   @CustID             INT            -- not null
)
AS
BEGIN

		SELECT 
				c.CustID,
				c.CallerID,
				c.Active,
				c.ConsumerType,
				0 as PositionID,
				'' as Pwd,
				t.UserTokenTypeID,
				t.Hash,
				t.Salt,
				t.UpdatedUTC
		FROM Customer c
		LEFT JOIN CustomerToken t
			ON c.CustID = t.CustID
		WHERE c.CustID = @CustID
		ORDER BY t.UserTokenTypeID
	
END
GO

GRANT EXECUTE ON [TokenGen_SelectCustomerWithTokenRows] TO ExecuteOnlyRole
GO