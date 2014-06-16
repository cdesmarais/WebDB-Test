if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResourceLocator_GetDinersChoiceOverrides]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[svcResourceLocator_GetDinersChoiceOverrides]
GO

CREATE PROCEDURE [dbo].[svcResourceLocator_GetDinersChoiceOverrides]
AS
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		StandardUrl, NLURL
FROM		dbo.NLOverridesDinersChoice
ORDER BY	StandardUrl

GO

GRANT EXECUTE ON [svcResourceLocator_GetDinersChoiceOverrides] TO ExecuteOnlyRole
GO
