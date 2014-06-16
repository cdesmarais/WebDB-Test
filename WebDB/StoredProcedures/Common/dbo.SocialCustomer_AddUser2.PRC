if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SocialCustomer_AddUser2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SocialCustomer_AddUser2]
go

create Procedure dbo.SocialCustomer_AddUser2
 (
  @UserID int,
  @IsCaller bit,
  @SocialTypeID int, 
  @SocialUserID nvarchar(50),
  @SocialAccessToken varchar(255)
 )
as

set nocount on
set transaction isolation level read uncommitted

if @IsCaller = 1
begin
	--Update the caller's social data if it has changed
	if exists (	select		SiteUserID 
				from		SocialCaller 
				where		CallerID = @UserID 
				and			SocialTypeID = @SocialTypeID)
		begin
				update		SocialCaller 
				set			SiteUserID = @SocialUserID,
							SocialAccessToken = @SocialAccessToken
				where		CallerID = @UserID 
				and			SocialTypeID = @SocialTypeID
		end
	else
	--New social data for caller
		begin
				insert into SocialCaller (CallerID, SocialTypeID, SiteUserID, SocialAccessToken)
				values		(@UserID, @SocialTypeID, @SocialUserID, @SocialAccessToken)
		end
end
else
begin
	--Update the customer's social data if it has changed
	if exists (	select		SiteUserID 
				from		SocialCustomer 
				where		CustID = @UserID 
				and			SocialTypeID = @SocialTypeID)
		begin
				update		SocialCustomer 
				set			SiteUserID = @SocialUserID,
							SocialAccessToken = @SocialAccessToken
				where		CustID = @UserID 
				and			SocialTypeID = @SocialTypeID
		end
	else
	--New social data for customer	
		begin
				insert into SocialCustomer (CustID, SocialTypeID, SiteUserID, SocialAccessToken)
				values		(@UserID, @SocialTypeID, @SocialUserID, @SocialAccessToken)
		end
end

go

grant execute on [SocialCustomer_AddUser2] TO ExecuteOnlyRole

go
