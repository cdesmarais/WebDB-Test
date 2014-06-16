if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Dump_CustomerByEMail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Dump_CustomerByEMail]
GO




CREATE Procedure dbo.Dump_CustomerByEMail
 (
  @EMail nvarchar(255)
 )
As
SET NOCOUNT ON
/*NOTE: this stored proc was adjusted for the new CreditCard schema ... but the wrapping logic/functionality should
also be adjusted since customers might soon have more than one credit card (8-7-00) ... */
SELECT *
FROM Customer
WHERE (Email = @EMail)
SELECT CreditCard.*
FROM CreditCard INNER JOIN
    Customer ON 
    CreditCard.CustID = Customer.CustID
WHERE (Customer.Email = @EMail)
SELECT CustomerPhone.*
FROM CustomerPhone INNER JOIN
    Customer ON 
    CustomerPhone.CustID = Customer.CustID AND CustomerPhone.IsPrimary = 1
WHERE (Customer.Email = @EMail)




GO

GRANT EXECUTE ON [Dump_CustomerByEMail] TO ExecuteOnlyRole

GO
