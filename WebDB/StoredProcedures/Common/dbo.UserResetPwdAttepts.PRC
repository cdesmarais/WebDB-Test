if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserResetPwdAttepts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserResetPwdAttepts]
GO



CREATE Procedure dbo.UserResetPwdAttepts
 (
  @userID int,
  @isCaller int
 )
As
SET NOCOUNT ON
Delete from FailedLoginCounter where UserID = @userID and isAdmin = @isCaller
GO


GRANT EXECUTE ON [UserResetPwdAttepts] TO ExecuteOnlyRole

GO
