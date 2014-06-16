if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SocialCustomer_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SocialCustomer_Delete]
GO

CREATE Procedure dbo.Admin_SocialCustomer_Delete
 (
  @UserID int,
  @IsCaller bit,
  @SocialTypeID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if @IsCaller = 1
BEGIN
	delete from SocialCaller where CallerID = @UserID and SocialTypeID = @SocialTypeID
END
else
BEGIN
	delete from SocialCustomer where CustID = @UserID and SocialTypeID = @SocialTypeID
END

GO

GRANT EXECUTE ON [Admin_SocialCustomer_Delete] TO ExecuteOnlyRole

GO
