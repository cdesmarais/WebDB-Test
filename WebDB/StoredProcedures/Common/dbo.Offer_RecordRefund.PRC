if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_RecordRefund]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_RecordRefund]
GO

CREATE procedure dbo.Offer_RecordRefund
 ( 
	 @OfferTxnID		int
	,@RequestID			varchar(26)
	,@ReconciliationID	varchar(60)
	,@Decision			varchar(50)
	,@ReasonCode		int
	,@Amount			smallmoney
	,@Currency			varchar(5)
 )
As
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE

-- TODO: Parameterize the PaymentProviderID when we get another payment provider
declare  @PaymentProviderID int = 1 -- CyberSource
		,@PaymentDecisionID int = 0 -- UNKNOWN
	
-- Convert decision string argument to ID
select	@PaymentDecisionID	= PaymentDecisionID
from	PaymentDecision
where	Status				= @Decision
and		PaymentProviderID	= @PaymentProviderID


BEGIN TRANSACTION MyTransaction			
	
	INSERT INTO	dbo.OffersRefund (
				 OfferTxnID
				,RequestID
				,ReconciliationID
				,PaymentDecisionID
				,ReasonCode
				,Amount
				,Currency
	) VALUES (
				 @OfferTxnID
				,@RequestID
				,@ReconciliationID
				,@PaymentDecisionID
				,@ReasonCode
				,@Amount
				,@Currency
	)	

	IF (@@ERROR <> 0) 
		GOTO general_error	
	
COMMIT TRAN
RETURN(0)


-- Handle Error cases.
general_error:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('6',16,2) --Error adding new OffersRefund.
	RETURN(5)
GO

GRANT EXECUTE ON [Offer_RecordRefund] TO ExecuteOnlyRole
GO
