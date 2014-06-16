--Create Stored Proc
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_RemoveFBAuthToken]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_RemoveFBAuthToken]
GO

CREATE PROCEDURE [dbo].[UserSvc_RemoveFBAuthToken]

@SocialID		NVARCHAR(50),
@SocialTypeID	INT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--Per CK currently it's not enough to just remove the AuthToken from the table; we actually
--need to delete the record. Eventually Ck's team will be achanging the design so we can do
--it with just making the Authtoken NULL. So temporarily we need to use DELETE.

DELETE		SocialCustomer	
WHERE		SiteUserID = @SocialID 
AND			SocialTypeID = @SocialTypeID

DELETE		SocialCaller
WHERE		SiteUserID = @SocialID
AND			SocialTypeID = @SocialTypeID

GO

GRANT EXECUTE ON [UserSvc_RemoveFBAuthToken] TO ExecuteOnlyRole

GO
