if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResourceLocator_GetRestProfileOverrides]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[svcResourceLocator_GetRestProfileOverrides]
GO

CREATE PROCEDURE [dbo].[svcResourceLocator_GetRestProfileOverrides]
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
	dbo.NLOverridesRestProfile
WHERE
	(@UpdatedSince IS NULL) OR (LastModifiedLocal > @UpdatedSince)

ORDER BY LastModifiedLocal DESC
GO

GRANT EXECUTE ON [svcResourceLocator_GetRestProfileOverrides] TO ExecuteOnlyRole
GO