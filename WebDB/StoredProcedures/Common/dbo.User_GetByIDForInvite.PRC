if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetByIDForInvite]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetByIDForInvite]
GO

CREATE Procedure dbo.User_GetByIDForInvite
 (
  @UserID int,
  @CustomerID int,
  @IsCaller int=0
 )
As


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if(@IsCaller = 0)
	BEGIN
	SELECT Customer.FName AS FirstName,
    	    Customer.LName AS LastName,
    	    Customer.EMail
	FROM Customer LEFT OUTER JOIN CustomerPhone ON 
                  Customer.CustID = CustomerPhone.CustID
	WHERE (Customer.CustID = @UserID) AND 
    	    (CustomerPhone.IsPrimary = 1)
	END
if(@IsCaller <> 0)
	BEGIN
	SELECT CallerCustomer.FName AS FirstName,
    	    CallerCustomer.LName AS LastName,
    	    CallerCustomer.EMail
	FROM Caller Left Outer Join CallerCustomer
	    On Caller.CallerID=CallerCustomer.CallerID
	    LEFT OUTER JOIN CallerPhone ON 
    	    Caller.CallerID = CallerPhone.CallerID
	WHERE (Caller.CallerID = @UserID) AND 
    	    (CallerPhone.IsPrimary = 1) AND
    	    (Caller.PositionID = 3) AND (CallerCustomer.CustID = @CustomerID)
	End
GO

GRANT EXECUTE ON [User_GetByIDForInvite] TO ExecuteOnlyRole

GO
