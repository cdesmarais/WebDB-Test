if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_GetLoginInfoForEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_GetLoginInfoForEmail]
GO


CREATE PROCEDURE [dbo].[UserSvc_GetLoginInfoForEmail]
(
	@Email nvarchar(75)
)
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF EXISTS(SELECT [CustID] FROM [Customer] WHERE [Email] = @Email)
BEGIN
	SELECT	c.[CustID] AS 'UserID',
			CONVERT(BIT,0) AS 'IsCaller',
			c.[Email] AS 'LoginName',
			c.[Email] AS 'Email',
			'' AS 'Password',
			c.[PwdAttempt] AS 'LoginFailedCount',
			t.[UserTokenTypeID] AS 'UserTokenTypeID',
			t.[Hash] AS 'Hash',
			t.[Salt] AS 'Salt',
			c.[Active] AS 'Active' 
	FROM [Customer] c
	LEFT JOIN [CustomerToken] t ON t.[CustID] = c.[CustID]
	WHERE ([EMail] = @Email)
END
ELSE
BEGIN
	SELECT	c.[CallerID] AS 'UserID',
			CONVERT(BIT,1) AS 'IsCaller',
			c.[LoginName] AS 'LoginName',
			c.[Email] AS 'Email',
			'' AS 'Password',
			c.[PwdAttempt] AS 'LoginFailedCount',
			t.[UserTokenTypeID] AS 'UserTokenTypeID',
			t.[Hash] AS 'Hash',
			t.[Salt] AS 'Salt',
			(CASE WHEN(c.CallerStatusID > 1) THEN 0 ELSE 1 END) AS 'Active' 
	FROM [Caller] c
	LEFT JOIN [CallerToken] t ON t.[CallerID] = c.[CallerID]
	WHERE ([LoginName] = @Email)
END
GO

GRANT EXECUTE ON [dbo].[UserSvc_GetLoginInfoForEmail] TO ExecuteOnlyRole
GO
