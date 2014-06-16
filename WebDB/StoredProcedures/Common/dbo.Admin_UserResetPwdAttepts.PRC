if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UserResetPwdAttepts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UserResetPwdAttepts]
GO



CREATE PROCEDURE dbo.Admin_UserResetPwdAttepts
 (
  @userID int,
  @isCaller int
 )
As
SET NOCOUNT ON

Delete from FailedLoginCounter where UserID = @userID and isAdmin = @isCaller
GO



GRANT EXECUTE ON [Admin_UserResetPwdAttepts] TO ExecuteOnlyRole

GO
