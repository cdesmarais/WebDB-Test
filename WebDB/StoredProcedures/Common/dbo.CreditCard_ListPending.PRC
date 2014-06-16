if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditCard_ListPending]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditCard_ListPending]
GO



CREATE PROCEDURE dbo.CreditCard_ListPending
As
SET NOCOUNT ON

SELECT CreditCard.CreditCardID AS CreditCardID,
    CreditCard.CardNumber AS CreditCardNumber,
    CreditCard.ExpDate AS ExpirationDate,
    Customer.FName AS FirstName,
    Customer.LName AS LastName,
    Customer.Address1 as Address,Customer.City,
    Customer.State,
    Customer.Zip AS ZipCode,
    Customer.Country
FROM CreditCard INNER JOIN
    Customer ON 
    CreditCard.CustID = Customer.CustID
WHERE (CreditCard.StatusID = 1)
union
SELECT CreditCard.CreditCardID AS CreditCardID,
    CreditCard.CardNumber AS CreditCardNumber,
    CreditCard.ExpDate AS ExpirationDate,
    CallerCustomer.FName AS FirstName,
    CallerCustomer.LName AS LastName,
     'unknown' as Address,'unknown' as City,
     'unknown' as State,
     'unknown'  AS ZipCode,
     'unknown' as Country
FROM CreditCard INNER JOIN
    CallerCustomer ON 
    CreditCard.CustID = CallerCustomer.CustID
WHERE (CreditCard.StatusID = 1)
GO

GRANT EXECUTE ON [CreditCard_ListPending] TO ExecuteOnlyRole

GO
