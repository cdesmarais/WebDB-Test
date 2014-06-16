if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CustomerGetByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CustomerGetByEmail]
GO

CREATE Procedure dbo.CustomerGetByEmail
 (
  @Email nvarchar(255)
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if exists(Select CustID from Customer where Email = @Email)
BEGIN
	SELECT CustID AS UserID
		,FName AS FirstName
		,LName AS LastName
		,'' as Password
		,metroareaid AS DefaultGeoID
		,Points
		,Active
		,ConsumerType as Consumer_Type
		,0 as isCaller
		,UpdatedFavorites
	FROM Customer
	WHERE (EMail = @Email)
END
else
BEGIN
	SELECT CallerID AS UserID
		,FName AS FirstName
		,LName AS LastName
		,'' as Password
		,metroareaid AS DefaultGeoID
		,Points
		,CallerStatusID as Active
		,ConsumerType as Consumer_Type
		,1 as isCaller
		,UpdatedFavorites
	FROM Caller
	WHERE (EMail = @Email)
END

GO

GRANT EXECUTE ON [CustomerGetByEmail] TO ExecuteOnlyRole

GO
