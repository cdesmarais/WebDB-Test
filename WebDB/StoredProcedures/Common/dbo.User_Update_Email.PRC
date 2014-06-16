if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Update_Email]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Update_Email]
GO

CREATE Procedure dbo.User_Update_Email
 (
  @UserID int,
  @NewEmail nvarchar(255),
  @isCaller int = 0 --this procedure only works for Real_Customers
 )
As
SET NOCOUNT ON
declare @CurrentEmail nvarchar(255),@dup_UserID int,@ConsumerType int
SET DATEFORMAT mdy
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRAN
if @isCaller = 0
BEGIN

-- Check top see if an admin already has this email
if exists(Select CallerID from Caller where LoginName = @NewEmail) GOTO dup_email

-- Set the default to the current ID.
SELECT @dup_UserID = @UserID,@CurrentEmail = Email,@ConsumerType = ConsumerType from Customer where CustID =  @UserID

-- Ensure some other user doesn't already have this email address.
SELECT @dup_UserID = coalesce(CustID,@UserID) FROM Customer WHERE Email = @NewEmail
if (@dup_UserID <> @UserID) GOTO dup_email
	
	UPDATE Customer
	SET EMail = ltrim(rtrim(@NewEmail))
	WHERE (CustID = @UserID)

Select @CurrentEmail as OldEmail,@NewEmail as NewEmail,@UserID as UserID,@ConsumerType as ConsumerType

END
else
BEGIN

-- Check top see if an admin already has this email
if exists(Select CustID from Customer where email = @NewEmail) GOTO dup_email

-- Set the default to the current ID.
SELECT @dup_UserID = @UserID,@CurrentEmail = Email,@ConsumerType = ConsumerType from Caller where CallerID =  @UserID

-- Ensure some other user doesn't already have this email address.
SELECT @dup_UserID = coalesce(CallerID,@UserID) FROM Caller WHERE LoginName = @NewEmail
if (@dup_UserID <> @UserID) GOTO dup_email
	
	UPDATE Caller
	SET 
	EMail = ltrim(rtrim(@NewEmail)),
	LoginName = ltrim(rtrim(@NewEmail))
	WHERE (CallerID = @UserID)

Select @CurrentEmail as OldEmail,@NewEmail as NewEmail,@UserID as UserID,@ConsumerType as ConsumerType


END


COMMIT TRAN
RETURN(0)

dup_email:
ROLLBACK TRAN
RAISERROR('4',16,1)
RETURN(1)
GO

GRANT EXECUTE ON [User_Update_Email] TO ExecuteOnlyRole

GO
