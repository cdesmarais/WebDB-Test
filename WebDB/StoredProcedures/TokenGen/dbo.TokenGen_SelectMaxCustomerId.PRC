-- File: dbo.TokenGen_SelectMaxCustomerId.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_SelectMaxCustomerId]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_SelectMaxCustomerId
GO

CREATE PROCEDURE dbo.[TokenGen_SelectMaxCustomerId]

AS
BEGIN

		SELECT MAX(CustID) AS MaxID FROM Customer
	
END
GO

GRANT EXECUTE ON [TokenGen_SelectMaxCustomerId] TO ExecuteOnlyRole
GO