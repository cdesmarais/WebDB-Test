if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAllNLURLTranslations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[GetAllNLURLTranslations]
GO

CREATE PROCEDURE [dbo].[GetAllNLURLTranslations]
AS
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		OldUrl, NLURL
FROM		dbo.NLURLVW
ORDER BY	OldUrl

GO

GRANT EXECUTE ON [GetAllNLURLTranslations] TO ExecuteOnlyRole
GO
