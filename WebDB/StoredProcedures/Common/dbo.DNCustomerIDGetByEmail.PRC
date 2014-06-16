if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCustomerIDGetByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCustomerIDGetByEmail]
GO

CREATE Procedure dbo.DNCustomerIDGetByEmail
 (
  @Email nvarchar(255)
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if exists(Select CustID from Customer where Email = @Email)
BEGIN
	SELECT CustID AS UserID
		,ConsumerType as Consumer_Type
		,0 as isCaller
	FROM Customer
	WHERE (EMail = @Email)
END
else
BEGIN
	SELECT CallerID AS UserID
		,ConsumerType as Consumer_Type
		,1 as isCaller
	FROM Caller
	WHERE (loginName = @Email)
END

GO

GRANT EXECUTE ON [DNCustomerIDGetByEmail] TO ExecuteOnlyRole

GO
