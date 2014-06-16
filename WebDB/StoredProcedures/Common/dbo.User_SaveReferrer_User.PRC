if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SaveReferrer_User]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SaveReferrer_User]
GO

CREATE PROCEDURE dbo.User_SaveReferrer_User
(
@Referring_CustomerID nvarchar(255),
@Referring_CallerID int,
@CustomerID int,
@CallerID int,
@retval int OUTPUT
)
AS

SET NOCOUNT ON

if @CustomerID > 0
 Begin
	if not exists(Select CustID from ReferrerUserRegistration
	where CustID = @CustomerID)
	BEGIN
		Insert into ReferrerUserRegistration (ReferringCustID,ReferringCallerID,CustID,CallerID)
		values (@Referring_CustomerID,@Referring_CallerID,@CustomerID,@CallerID)
	END
 End 
    
if @CallerID > 0
Begin
	if not exists(Select CallerID from ReferrerUserRegistration
	where CallerID = @CallerID)
	BEGIN
		Insert into ReferrerUserRegistration (ReferringCustID,ReferringCallerID,CustID,CallerID)
		values (@Referring_CustomerID,@Referring_CallerID,@CustomerID,@CallerID)
	END
End

if (@@error <> 0) goto nogood
SELECT @retval= 1
RETURN(1)
nogood:
RETURN(0)
GO

GRANT EXECUTE ON [User_SaveReferrer_User] TO ExecuteOnlyRole

GO
