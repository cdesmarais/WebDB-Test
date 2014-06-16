
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetLanguages]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetLanguages
(
  @RID int
)
AS


SELECT	[Language].[LanguageID], 
		[LanguageCode], 
		[LanguageRegionDesc],
		[PrimaryLanguageID]
FROM	[Restaurant] r
INNER JOIN [RestaurantLocal] rl 
ON			r.[RID] = rl.[RID]
INNER JOIN	[Language] 
ON			rl.[LanguageID] = [Language].[LanguageID]
INNER JOIN	[Domain] d 
ON			r.[DomainID] = d.[DomainID]
WHERE		[Language].[Active] = 1
AND			d.[Active] = 1
AND			rl.RID = @RID

GO


GRANT EXECUTE ON [Admin_Restaurant_GetLanguages] TO ExecuteOnlyRole

GO
