if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetCustomerSocialInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetCustomerSocialInfo]
GO


CREATE PROCEDURE dbo.proc_UserSvc_GetCustomerSocialInfo
 (
  @UserID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	sc.SiteUserID as SocialUID,
		sc.SocialAccessToken,
		sc.SocialTypeID
FROM	SocialCustomer sc
WHERE	sc.CustID = @UserID

GO

GRANT EXECUTE ON [proc_UserSvc_GetCustomerSocialInfo] TO ExecuteOnlyRole

GO