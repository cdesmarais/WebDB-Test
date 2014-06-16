if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResourceLocator_GetSingleOverrides]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[svcResourceLocator_GetSingleOverrides]
GO

CREATE PROCEDURE [dbo].[svcResourceLocator_GetSingleOverrides]
	@UpdatedSince DATETIME
AS
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		
	RID
	,StandardUrl
	,NLURL
	,LastModifiedLocal
FROM 
	dbo.NLOverridesSingle
WHERE
	(@UpdatedSince IS NULL) OR (LastModifiedLocal > @UpdatedSince)

ORDER BY LastModifiedLocal DESC
GO

GRANT EXECUTE ON [svcResourceLocator_GetSingleOverrides] TO ExecuteOnlyRole
GO