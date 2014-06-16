if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_GetCreditCard]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_GetCreditCard]
GO

CREATE PROCEDURE dbo.Concierge_Reservation_Caller_GetCreditCard

@UserID int

AS

set transaction isolation level read uncommitted

Select top 1

PaymentType.PaymentType AS CreditCardType,
CreditCard.CardNumber AS CreditCardNumber,
CreditCard.ExpDate AS ExpirationDate,
lastmodified as Last_modified
FROM CreditCard 
INNER JOIN PaymentType 
ON CreditCard.CreditTypeID = PaymentType.PaymentTypeID
Where CreditCard.CustID = @UserID 
and IsPrimary = 1
Order by lastmodified desc

GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_GetCreditCard] TO ExecuteOnlyRole

GO
