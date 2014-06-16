if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procSocialCaller_GetUserById]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procSocialCaller_GetUserById]
go

create Procedure dbo.procSocialCaller_GetUserById
 (
  @UserID int
 )
As

set nocount on
set transaction isolation level read uncommitted

select			CallerID UserID
				,SocialTypeID
				,SiteUserID
				,SocialAccessToken
from			SocialCaller
where			(CallerID = @UserID)

go

grant execute on [procSocialCaller_GetUserById] to ExecuteOnlyRole

go
