if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RingRevenueUpdateRunLogEntry]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RingRevenueUpdateRunLogEntry]
GO

CREATE PROCEDURE [dbo].[RingRevenueUpdateRunLogEntry]
(
   @RunID              			INT, 
   @Status             			BIT,   
   @FirstTransactionIDReceived 	varchar(20),
   @LastTransactionIDReceived 	varchar(20),
   @TransactionCount   			INT,
   @EmailSentCount				INT
)
AS
	SET NOCOUNT ON
	UPDATE [dbo].[RingRevenueRunLog]
		SET [Status] = @Status,
			[FirstTransactionIDReceived] = @FirstTransactionIDReceived,
			[LastTransactionIDReceived] = @LastTransactionIDReceived,
			[TransactionCount]  = @TransactionCount,
			[EmailSentCount] = @EmailSentCount,
			[UpdateDtUTC] = getutcdate()
	WHERE [RunID] = @RunID

	SELECT @@ROWCOUNT
GO

GRANT EXECUTE ON [RingRevenueUpdateRunLogEntry] TO ExecuteOnlyRole
GO
