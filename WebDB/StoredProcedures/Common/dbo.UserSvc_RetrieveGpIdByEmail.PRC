--Create Stored Proc
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_RetrieveGpIdByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_RetrieveGpIdByEmail]
GO

CREATE PROCEDURE [dbo].[UserSvc_RetrieveGpIdByEmail]

@EMail		NVARCHAR(75)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@CustID		INT = 0;

--Check Customer Table First
SELECT			@CustID = [CustID] 
FROM			[Customer] 
WHERE			[Email] = @Email

IF (@CustID > 0)
BEGIN
	SELECT		CAST(_GlobalPersonID AS BIGINT) AS 'GPID'
	FROM		dbo.GlobalPerson 
	WHERE		CustID = @CustID
END
ELSE
BEGIN
	SELECT		CAST(_GlobalPersonID AS BIGINT) AS 'GPID'
	FROM		dbo.GlobalPerson p
	INNER JOIN	dbo.[Caller] c
	ON			p.CallerID = c.CallerID
	WHERE		c.LoginName = @EMail
END
GO

GRANT EXECUTE ON [UserSvc_RetrieveGpIdByEmail] TO ExecuteOnlyRole
GO
