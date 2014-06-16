if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procSocialCustomer_GetUserById]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procSocialCustomer_GetUserById]
go

create Procedure dbo.procSocialCustomer_GetUserById
 (
  @UserID int
 )
As

set nocount on
set transaction isolation level read uncommitted

select			CustID UserID
				,SocialTypeID
				,SiteUserID
				,SocialAccessToken
from			SocialCustomer
where			(CustID = @UserID)

go

grant execute on [procSocialCustomer_GetUserById] to ExecuteOnlyRole

go
