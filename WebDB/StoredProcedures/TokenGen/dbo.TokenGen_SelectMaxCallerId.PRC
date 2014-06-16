-- File: dbo.TokenGen_SelectMaxCallerId.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_SelectMaxCallerId]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_SelectMaxCallerId
GO

CREATE PROCEDURE dbo.[TokenGen_SelectMaxCallerId]

AS
BEGIN

		SELECT MAX(CallerID) AS MaxID FROM Caller
	
END
GO

GRANT EXECUTE ON [TokenGen_SelectMaxCallerId] TO ExecuteOnlyRole
GO