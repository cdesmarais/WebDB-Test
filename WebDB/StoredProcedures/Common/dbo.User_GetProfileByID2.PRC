if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetProfileByID2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetProfileByID2]
GO

CREATE PROCEDURE dbo.User_GetProfileByID2
(
	@UserID int
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT top 1
	PaymentType.PaymentType AS CreditCardType,
	CreditCard.CardNumber AS CreditCardNumber,
	CreditCard.ExpDate AS ExpirationDate,
	lastmodified as Last_modified
FROM CreditCard
inner join PaymentType on CreditCard.CreditTypeID = PaymentType.PaymentTypeID
WHERE CreditCard.CustID = @UserID and IsPrimary = 1
Order by lastmodified desc

GO

GRANT EXECUTE ON [User_GetProfileByID2] TO ExecuteOnlyRole

GO
