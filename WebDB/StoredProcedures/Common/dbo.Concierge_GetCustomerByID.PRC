if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_GetCustomerByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_GetCustomerByID]
GO

CREATE PROCEDURE dbo.Concierge_GetCustomerByID
 (
  @CustomerID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
if Exists	(Select 1 
		 From CallerCustomer 
		 inner join CreditCard 
		 on CallerCustomer.CustID = CreditCard.CustID 
		 Where CallerCustomer.CustID = @CustomerID
		 )
	Begin
	Select cc.FName As FirstName
	,cc.LName As LastName
	,cd.CreditTypeID As CardType
	,cd.CardNumber As CardNumber
	,cd.ExpDate As ExpiresDate
	,retval = 0
	From CallerCustomer cc
	inner join CreditCard  cd
	on cc.CustID = cd.CustID
	Where cc.CustID = @CustomerID
	Return(0)
	End

if Not Exists	(Select 1 
                 From CallerCustomer 
		 inner join CreditCard 
		 on CallerCustomer.CustID = CreditCard.CustID 
		 Where CallerCustomer.CustID = @CustomerID
		 )
	Begin
	Select cc.FName As FirstName
	,cc.LName As LastName
	,retval = 1
	From CallerCustomer cc
	Where cc.CustID = @CustomerID
	Return(1)
	End
GO

GRANT EXECUTE ON [Concierge_GetCustomerByID] TO ExecuteOnlyRole

GO
