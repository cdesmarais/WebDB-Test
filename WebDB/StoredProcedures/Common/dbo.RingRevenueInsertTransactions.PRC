if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RingRevenueInsertTransactions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RingRevenueInsertTransactions]
GO

CREATE PROCEDURE [dbo].[RingRevenueInsertTransactions]
(
      @RingRevenueTransactionDataTable RingRevenueTransactionDataTable READONLY  
)
AS
	SET NOCOUNT ON
	
	MERGE INTO  [dbo].[RingRevenueTransaction]  AS target
	USING  @RingRevenueTransactionDataTable  AS source
	ON  target.[TransactionID] = source.[TransactionID]
	WHEN NOT MATCHED THEN
		INSERT
		(
			[TransactionID],
			[TransactionTypeID],
			[OriginalOrderID],
			[AdvertiserID],
			[AdvertiserIDFromNetwork],
			[AdvertiserName],
			[AdvertiserCampaignID],
			[MediaType],
			[CallSourceDescription],
			[CallFeeLocalized],
			[AdvertiserCallFeeLocalized],
			[City],
			[Region],
			[CallingPhoneNumber],
			[PhoneTypeID],
			[Duration],
			[ConnectDuration],
			[IVRDuration],
			[StartTimeLocal]
		)
		VALUES 
		(
			source.[TransactionID],
			source.[TransactionTypeID],
			source.[OriginalOrderID],
			source.[AdvertiserID],
			source.[AdvertiserIDFromNetwork],
			source.[AdvertiserName],
			source.[AdvertiserCampaignID],
			source.[MediaType],
			source.[CallSourceDescription],
			source.[CallFeeLocalized],
			source.[AdvertiserCallFeeLocalized],
			source.[City],
			source.[Region],
			source.[CallingPhoneNumber],
			source.[PhoneTypeID],
			source.[Duration],
			source.[ConnectDuration],
			source.[IVRDuration],
			source.[StartTimeLocal]
		);
		
	SELECT @@ROWCOUNT
GO

GRANT EXECUTE ON [RingRevenueInsertTransactions] TO ExecuteOnlyRole
GO
