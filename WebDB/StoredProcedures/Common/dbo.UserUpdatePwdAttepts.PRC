if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserUpdatePwdAttepts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserUpdatePwdAttepts]
GO

CREATE Procedure dbo.UserUpdatePwdAttepts
 (
  @userID int,
  @isCaller int
 )
As
SET NOCOUNT ON

if exists(Select UserID from FailedLoginCounter where UserID = @userID and isAdmin = @isCaller)
BEGIN
	update FailedLoginCounter set LoginFailedCount = LoginFailedCount + 1, 
		LastLoginAttempt = getdate()
	where UserID = @userID and isAdmin = @isCaller
END
else
BEGIN
	Insert into FailedLoginCounter (UserID, isAdmin, LoginFailedCount, LastLoginAttempt)
	VALUES (@userID,@isCaller,1,getdate())
END

GO


GRANT EXECUTE ON [UserUpdatePwdAttepts] TO ExecuteOnlyRole

GO
