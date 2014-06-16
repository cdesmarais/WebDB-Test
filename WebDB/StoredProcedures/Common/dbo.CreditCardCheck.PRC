if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditCardCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditCardCheck]
GO



CREATE PROCEDURE dbo.CreditCardCheck
(
 @UserID int,
 @IsCaller int=0,
 @IsPrimary int = 1 --assume we are looking for primary credit card
)
/*NOTE: this stored proc used to fork on @IsCaller,but the new credit card schema (8-7-00) makes this un-necessary*/ 
 AS
 SET NOCOUNT ON

Select StatusID as status,
(Case
When datediff(m,getdate(),ExpDate ) < 0 Then 1 Else 0 End) As expired,
CardNumber as Card_Number,ExpDate as Expiration_Date,CreditTypeID as Credit_Type_ID,CreditCardID as Credit_Card_ID
From CreditCard
Where CustID = @UserID and
IsPrimary = @IsPrimary
GO

GRANT EXECUTE ON [CreditCardCheck] TO ExecuteOnlyRole

GO
