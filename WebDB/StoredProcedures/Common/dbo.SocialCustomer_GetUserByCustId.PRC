if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SocialCustomer_GetUserByCustId]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SocialCustomer_GetUserByCustId]
go

create Procedure dbo.SocialCustomer_GetUserByCustId
 (
  @UserID int,
  @IsCaller bit
 )
As

set nocount on
set transaction isolation level read uncommitted

if @IsCaller = 1
	select			CallerID  UserID
					,SocialTypeID
					,SiteUserID
					,SocialAccessToken
	from			SocialCaller
	where			(CallerID = @UserID)
else
	select			CustID UserID
					,SocialTypeID
					,SiteUserID
					,SocialAccessToken
	from			SocialCustomer
	where			(CustID = @UserID)

go

grant execute on [SocialCustomer_GetUserByCustId] to ExecuteOnlyRole

go
