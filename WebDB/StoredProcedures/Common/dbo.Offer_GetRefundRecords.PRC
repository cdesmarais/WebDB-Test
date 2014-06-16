if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_GetRefundRecords]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_GetRefundRecords]
GO

CREATE procedure dbo.Offer_GetRefundRecords
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Offer transactions linked to cancelled resos:
SELECT oft.OfferTxnID
   ,oft.OrderNumber
   ,oft.RequestID
   ,oft.ReconciliationID
   ,oft.PaymentDecisionID
   ,oft.ReasonCode
   ,oft.MakeConfirmed
   ,oft.ProviderConfirmed        
   ,oft.Amount
   ,oft.Currency                       
   ,'NEEDS REFUND, RESO CANCELLED' as 'TransactionState'
   ,1 as 'NeedsRefund'
   ,oft.CreateDT     
FROM        OfferTxn          oft
LEFT JOIN   OffersRefund      ofr
ON                oft.OfferTxnID    = ofr.OfferTxnID
LEFT JOIN   ReservationOffer ro
ON                oft.OfferTxnID    = ro.OfferTxnID
LEFT JOIN   Reservation       rv
ON                rv.ResID          = ro.ResID
WHERE (oft.PaymentDecisionID        = 1         -- payment accepted
      AND ISNULL(rv.RStateID,0) IN(3,8,9)       -- and reso is cancelled (web, restaurant or disputed)
      AND rv.ShiftDate >= getdate() - 90        -- and reso is for future/last 90 days (Reservation view perf optimization)
      AND oft.ProviderConfirmed     = 1         -- and CyberSource Confirmed
      AND ofr.OfferRefundID         IS NULL)    -- and no refund record
                              
UNION

-- Offer transactions without resos: 
SELECT oft.OfferTxnID
   ,oft.OrderNumber
   ,oft.RequestID
   ,oft.ReconciliationID
   ,oft.PaymentDecisionID
   ,oft.ReasonCode
   ,oft.MakeConfirmed
   ,oft.ProviderConfirmed        
   ,oft.Amount
   ,oft.Currency                       
   ,'NEEDS REFUND, NO RESO' as 'TransactionState'
   ,1 as 'NeedsRefund'
   ,oft.CreateDT          
FROM        OfferTxn          oft
LEFT JOIN   OffersRefund      ofr
ON                oft.OfferTxnID    = ofr.OfferTxnID
LEFT JOIN   ValueLookup       v 
ON                v.LKey            = 'MINS_TO_REFUND_OFFER'
AND               v.LType           = 'WEBSERVER'
WHERE (oft.PaymentDecisionID        = 1         -- payment accepted
      AND oft.MakeConfirmed         = 0         -- and no reso
      AND ofr.OfferRefundID         IS NULL     -- and no refund record
      AND oft.ProviderConfirmed     = 1         -- and CyberSource Confirmed
                                                -- and payment has been in the db more than the minute threshold to refund
      AND (getdate() > DATEADD(minute, COALESCE(v.ValueInt, 15), oft.CreateDT)))

GO

GRANT EXECUTE ON [Offer_GetRefundRecords] TO ExecuteOnlyRole
GO
