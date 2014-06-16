if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetByEmail]
GO

CREATE Procedure dbo.User_GetByEmail
 (
  @Email nvarchar(255)
 )
As

SET NOCOUNT ON
SELECT CustID AS UserID,FName AS FirstName
	,LName AS LastName
	,'' as Password
	,metroareaid AS DefaultGeoID
	,Points
	,Active
	,ConsumerType as Consumer_Type
	, coalesce((Select LoginFailedCount from FailedLoginCounter where UserID = Customer.CustID and isAdmin = 0),0) as PwdAttempt
FROM Customer
WHERE (EMail = @Email) --and ConsumerType <> 8
GO

GRANT EXECUTE ON [User_GetByEmail] TO ExecuteOnlyRole

GO
