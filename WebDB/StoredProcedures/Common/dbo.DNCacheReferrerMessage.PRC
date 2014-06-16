if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheReferrerMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheReferrerMessage]
GO


CREATE PROCEDURE dbo.DNCacheReferrerMessage
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	ReferrerID
		,LanguageID
		,[Message]
		,DateAdded
		,ReferrerMessageTypeID
FROM	dbo.ReferrerMessage

GO

GRANT EXECUTE ON [DNCacheReferrerMessage] TO ExecuteOnlyRole

GO
