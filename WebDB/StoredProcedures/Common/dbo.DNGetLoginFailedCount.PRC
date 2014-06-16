if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetLoginFailedCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetLoginFailedCount]
GO

CREATE PROCEDURE dbo.DNGetLoginFailedCount
(
	@UserID int,
	@IsAdmin bit
)
 AS
if exists(select LoginFailedCount from FailedLoginCounter where UserID = @UserID and IsAdmin = @IsAdmin)
	Begin
		select LoginFailedCount from FailedLoginCounter where UserID = @UserID and IsAdmin = @IsAdmin		
	End
else
	Begin
		insert into FailedLoginCounter 
			(UserID,IsAdmin,LoginFailedCount,LastLoginAttempt) 
			values (@UserID,@IsAdmin,1,getdate())
		select 1
	End
GO


GRANT EXECUTE ON [DNGetLoginFailedCount] TO ExecuteOnlyRole

GO
