if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetCallerSocialInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetCallerSocialInfo]
GO


CREATE PROCEDURE dbo.proc_UserSvc_GetCallerSocialInfo
 (
  @UserID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	sc.SiteUserID as SocialUID,
		sc.SocialAccessToken,
		sc.SocialTypeID
FROM	SocialCaller sc
WHERE	sc.CallerID = @UserID

GO

GRANT EXECUTE ON [proc_UserSvc_GetCallerSocialInfo] TO ExecuteOnlyRole

GO
