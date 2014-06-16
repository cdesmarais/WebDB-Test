if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNIncrementLoginFailedCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNIncrementLoginFailedCount]
GO

CREATE PROCEDURE dbo.DNIncrementLoginFailedCount
(
	@UserID int,
	@IsAdmin bit
)
AS
set transaction isolation level read uncommitted

declare @FailCount int

select	@FailCount = LoginFailedCount 
from	FailedLoginCounter 
where	UserID = @UserID 
and		IsAdmin = @IsAdmin

if @FailCount is not null
	Begin
		update FailedLoginCounter 
			set LoginFailedCount = LoginFailedcount + 1, LastLoginAttempt = getdate() 
			where UserID = @UserID and IsAdmin = @IsAdmin

	End
else
	Begin
		insert into FailedLoginCounter 
			(UserID,IsAdmin,LoginFailedCount,LastLoginAttempt) 
			values (@UserID,@IsAdmin,1,getdate())
	End

select IsNull(@FailCount,0) + 1 as LoginFailedCount

GO


GRANT EXECUTE ON [DNIncrementLoginFailedCount] TO ExecuteOnlyRole

GO
