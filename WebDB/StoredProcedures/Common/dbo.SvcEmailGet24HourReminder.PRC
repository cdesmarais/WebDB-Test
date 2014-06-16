IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SvcEmailGet24HourReminder]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SvcEmailGet24HourReminder]
GO

CREATE PROCEDURE [dbo].[SvcEmailGet24HourReminder]
AS
BEGIN
	---------------------------------------------------------------------
	-- [SvcEmailGet24HourReminder] is now divided into two procedures
	-- [SvcEmailGet24HourReminder] & [dbo].[procEmailGet24HourReminder]
	-- Modified to pass @dtNow as a parameter to the stored procedure
	-- so the QO will know the value of the parameter and will
	-- eliminate unnecessary partitions.
	--
	---------------------------------------------------------------------
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	declare @dtNow datetime
	set @dtNow = getdate()

	EXEC dbo.procEmailGet24HourReminder @dtNow
END
GO

GRANT EXECUTE ON [SvcEmailGet24HourReminder] TO ExecuteOnlyRole
GO
