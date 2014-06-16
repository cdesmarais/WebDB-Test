if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResetLoginFailedCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResetLoginFailedCount]
GO

CREATE PROCEDURE dbo.DNResetLoginFailedCount
(
	@UserID int,
	@IsAdmin bit
)
 AS
 
if exists(select LoginFailedCount from FailedLoginCounter where UserID = @UserID and IsAdmin = @IsAdmin)
	Begin
		update FailedLoginCounter 
			set LoginFailedCount = 0
			where	UserID = @UserID 
			and		IsAdmin = @IsAdmin
			and		LoginFailedCount != 0
	End
else
	Begin
		insert into FailedLoginCounter 
			(UserID,IsAdmin,LoginFailedCount) 
			values (@UserID,@IsAdmin,0)
	End


GO

GRANT EXECUTE ON [DNResetLoginFailedCount] TO ExecuteOnlyRole

GO
