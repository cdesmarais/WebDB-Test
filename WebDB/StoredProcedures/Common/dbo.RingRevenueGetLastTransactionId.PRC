if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RingRevenueGetLastTransactionId]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RingRevenueGetLastTransactionId]
GO

CREATE PROCEDURE [dbo].[RingRevenueGetLastTransactionId]
	AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SELECT ISNULL(LastTransactionIDReceived, AfterTransactionID)
	FROM [dbo].[RingRevenueRunLog] rl
	INNER JOIN (
		SELECT MAX(RunDtUTC) AS RunDtUTC_Max
		FROM [dbo].[RingRevenueRunLog]
		WHERE [Status] =1 
	) rdt
	ON rl.RunDtUTC = rdt.RunDtUTC_Max
GO

GRANT EXECUTE ON [RingRevenueGetLastTransactionId] TO ExecuteOnlyRole
GO
