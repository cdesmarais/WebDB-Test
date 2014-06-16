-- File: dbo.TokenGen_SelectCallerWithTokenRows.PRC in WebDB
-- A temporary proc to support TokenGen.exe tool for the purpose of OT user password migration.

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TokenGen_SelectCallerWithTokenRows]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.TokenGen_SelectCallerWithTokenRows
GO

CREATE PROCEDURE dbo.[TokenGen_SelectCallerWithTokenRows]
(
   @CallerID           INT            -- not null
)
AS
BEGIN

		SELECT 
				NULL as CustID,
				c.CallerID,
				CAST (CASE WHEN c.CallerStatusID = 1 THEN 1 ELSE 0 END AS BIT) as Active,
				c.ConsumerType,
				c.PositionID,
				'' as Pwd,
				t.UserTokenTypeID,
				t.Hash,
				t.Salt,
				t.UpdatedUTC
		FROM Caller c
		LEFT JOIN CallerToken t
			ON c.CallerID = t.CallerID
		WHERE c.CallerID = @CallerID
		ORDER BY t.UserTokenTypeID
	
END
GO

GRANT EXECUTE ON [TokenGen_SelectCallerWithTokenRows] TO ExecuteOnlyRole
GO