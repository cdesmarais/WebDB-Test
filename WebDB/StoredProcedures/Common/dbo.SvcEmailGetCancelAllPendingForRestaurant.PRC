IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SvcEmailGetCancelAllPendingForRestaurant]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SvcEmailGetCancelAllPendingForRestaurant]
GO


CREATE PROCEDURE [dbo].[SvcEmailGetCancelAllPendingForRestaurant]
AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @dtNow DATETIME
	SET @dtNow = GETDATE()
BEGIN
	---------------------------------------------------------------------
	-- Large queries against the Reservation table take a long time due
	-- partly to the fact that the row set it not limited until after
	-- the joins to the other tables.  This temp table is used to limit
	-- the row set as early as possible to increase performance.
	--
	-- Modified to pass @dtNow as a parameter to the stored procedure
	-- so the QO will know the value of the parameter and will
	-- eliminate unnecessay partitions.

EXEC dbo.procEmailGetCancelAllPendingForRestaurant @dtNow
END
GO

GRANT EXECUTE ON dbo.SvcEmailGetCancelAllPendingForRestaurant TO ExecuteOnlyRole
GO