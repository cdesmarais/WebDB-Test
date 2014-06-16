if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SocialCustomer_GetUserBySiteUserID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SocialCustomer_GetUserBySiteUserID]
go

create Procedure dbo.SocialCustomer_GetUserBySiteUserID
 (
  @SocialTypeID int,
  @SocialID nvarchar(50)
 )
as

set nocount on
set transaction isolation level read uncommitted

if exists(	Select			CallerID
			from			SocialCaller 
			where			SocialTypeID = @SocialTypeID 
			and				SiteUserID = @SocialID)
	
			select			CallerID UserID
							,SocialTypeID
							,SiteUserID
							,1 IsCaller
							,SocialAccessToken
			from			SocialCaller
			where			(SocialTypeID = @SocialTypeID 
			and				SiteUserID = @SocialID)
else 
			select			CustID UserID
							,SocialTypeID
							,SiteUserID
							,0 IsCaller
							,SocialAccessToken
			from			SocialCustomer
			where			(SocialTypeID = @SocialTypeID 
			and				SiteUserID = @SocialID)

go

grant execute on [SocialCustomer_GetUserBySiteUserID] to ExecuteOnlyRole

go
