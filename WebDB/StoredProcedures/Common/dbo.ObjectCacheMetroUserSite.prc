if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheMetroUserSite]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheMetroUserSite]
GO

CREATE Procedure [dbo].[ObjectCacheMetroUserSite]
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  SELECT	MetroAreaID as MetroId
			,MetroAreaName as MetroName
			,CountryID as CountryId
			,LanguageCode
			,MetroAreaSName as MetroSortableName
			 		
  FROM		 MetroAreaVW m 
  INNER JOIN Language l
  ON		 m.LanguageID = l.LanguageID
  WHERE		 m.Active = 1
  AND		 m.SupportedDomainID != 0
  ORDER BY	 MetroSortableName, MetroName

GO

GRANT EXECUTE ON [ObjectCacheMetroUserSite] TO ExecuteOnlyRole

GO


