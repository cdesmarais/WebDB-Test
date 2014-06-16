if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SocialCustomer_AddUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SocialCustomer_AddUser]
GO

CREATE Procedure dbo.SocialCustomer_AddUser
 (
  @UserID int,
  @IsCaller bit,
  @SocialTypeID int, 
  @SocialUserID nvarchar(50)
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if exists (select SiteUserID from SocialCaller where SiteUserID = @SocialUserID and SocialTypeID = @SocialTypeID)
	or exists (select SiteUserID from SocialCustomer where SiteUserID = @SocialUserID and SocialTypeID = @SocialTypeID)
BEGIN
	Raiserror(N'Social Account already linked',16,1)
	Return (1)
END

if @IsCaller = 1
BEGIN
	if exists (select SiteUserID from SocialCaller where CallerID = @UserID and SocialTypeID = @SocialTypeID)
	begin
		update SocialCaller set SiteUserID = @SocialUserID where CallerID = @UserID and SocialTypeID = @SocialTypeID
	end
	else
	begin
		insert into SocialCaller (CallerID, SocialTypeID, SiteUserID)
			values (@UserID, @SocialTypeID, @SocialUserID)
	end
END
else
BEGIN
	if exists (select SiteUserID from SocialCustomer where CustID = @UserID and SocialTypeID = @SocialTypeID)
	begin
		update SocialCustomer set SiteUserID = @SocialUserID where CustID = @UserID and SocialTypeID = @SocialTypeID
	end
	else
	begin
		insert into SocialCustomer (CustID, SocialTypeID, SiteUserID)
			values (@UserID, @SocialTypeID, @SocialUserID)
	end
END

GO

GRANT EXECUTE ON [SocialCustomer_AddUser] TO ExecuteOnlyRole

GO
