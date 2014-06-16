if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_RecordTransaction2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_RecordTransaction2]
GO

-- Insert or update row in OfferTxn table

CREATE procedure dbo.Offer_RecordTransaction2
 (     
	 @OrderNumber		varchar(50)
	,@RequestID			varchar(26)
	,@ReconciliationID	varchar(60)
	,@Decision			varchar(25)
	,@ReasonCode		int
	,@MakeConfirmed		bit			-- 1 to set field; 0 to clear field; null to leave as is
	,@ProviderConfirmed	bit			-- 1 to set field; 0 to clear field; null to leave as is
	,@Amount			smallmoney
	,@Currency			varchar(5)
	,@IsRepeatOrder		bit output  -- Output 1 if this is new RequestID for an existing OrderNumber; else 0
	,@ReturnValue		int output  -- Return OfferTxnID of row updated/inserted
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

SET @IsRepeatOrder = 0  -- Assume not a repeat order, unless proven otherwise

-- Does same OrderNbr exists for a different RequestID?
SELECT	@IsRepeatOrder = 1
FROM	OfferTxn 
WHERE	OrderNumber = @OrderNumber
AND ISNULL(RequestID,-1) <> ISNULL(@RequestID,-1)
AND RequestID IS NOT NULL
		
BEGIN TRANSACTION MyTransaction
	
	BEGIN
	
		IF @ProviderConfirmed = 1
		
		BEGIN
			-- Data has come directly from provider via the most reliable path.
			-- Supplied field values are definitive and should override existing values.
			-- Therefore, update all fields except possibly MakeConfirmed.
			UPDATE	OfferTxn
			SET		ReconciliationID	= @ReconciliationID
					,PaymentDecisionID	= @PaymentDecisionID
					,ReasonCode			= @ReasonCode
					,MakeConfirmed		= ISNULL(@MakeConfirmed, MakeConfirmed)
					,ProviderConfirmed	= 1
					,Amount				= @Amount
					,Currency			= @Currency
			WHERE	OrderNumber			= @OrderNumber
			AND		ISNULL(RequestID,-1)= ISNULL(@RequestID,-1)

		END
		
		ELSE -- @ProviderConfirmed <> 1 
		
		BEGIN
			-- Data has not come from provider but has come via less reliable path.
			-- Supplied field values must not, for the most part, replace existing values.
			-- Update only MakeConfirmed and ProviderConfirmed, and then only when parameters are non-null.
			UPDATE	OfferTxn
			SET		MakeConfirmed		= ISNULL(@MakeConfirmed, MakeConfirmed)
					,ProviderConfirmed	= ISNULL(@ProviderConfirmed, ProviderConfirmed)
			WHERE	OrderNumber			= @OrderNumber
			AND		ISNULL(RequestID,-1)= ISNULL(@RequestID,-1)
		END

		IF @@ROWCOUNT = 0 
		BEGIN	

			---- insert new record
			INSERT INTO	dbo.OfferTxn (
						 OrderNumber
						,RequestID
						,ReconciliationID
						,PaymentDecisionID
						,ReasonCode
						,MakeConfirmed
						,ProviderConfirmed
						,Amount
						,Currency
			) VALUES (
						 @OrderNumber
						 ,@RequestID
						 ,@ReconciliationID
						 ,@PaymentDecisionID
						 ,@ReasonCode
						 ,ISNULL(@MakeConfirmed,0)
						 ,ISNULL(@ProviderConfirmed,0)
						 ,@Amount
						 ,@Currency
			)	

			set @ReturnValue =  SCOPE_IDENTITY()
			
		END 
		ELSE
		BEGIN
			select	@ReturnValue = OfferTxnID
			from	OfferTxn with (nolock)
			where	OrderNumber = @OrderNumber
			AND		ISNULL(RequestID,-1)= ISNULL(@RequestID,-1)
		END

		IF (@@ERROR <> 0) 
			GOTO general_error	
	END 	

	COMMIT TRAN
	RETURN(0)


-- Handle Error cases.
general_error:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('6',16,2) --Error adding new OfferTxn.
	RETURN(5)
GO

GRANT EXECUTE ON [Offer_RecordTransaction2] TO ExecuteOnlyRole
GO
