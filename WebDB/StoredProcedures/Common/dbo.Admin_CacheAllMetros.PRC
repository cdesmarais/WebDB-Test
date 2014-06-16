if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllMetros]
GO

CREATE procedure [dbo].[Admin_CacheAllMetros] 
AS
SET NOCOUNT ON

	SELECT 	metroareaid as Metro_Area_ID,
			MetroAreaName as Name,
			MetroAreaAVW.Active,
			d.DomainID,
			d.Domain,
			MetroAreaAVW.LanguageID,
			d.PrimaryLanguageID,
			CASE WHEN (LEN(LTRIM(MetroAreaSName)) = 0) THEN MetroAreaName ELSE MetroAreaSName END SName,
			MetroAreaAVW.CountryID,
			metroareaid as GeoID,
			MetroAreaName as GeoName,
			ShowRegionLists
	FROM 	MetroAreaAVW -- Get metro info from all Languages
	inner join [Domain] d
	on	MetroAreaAVW.SupportedDomainID =  d.DomainID
	order	by Domain, LanguageID, SName



GO

GRANT EXECUTE ON [Admin_CacheAllMetros] TO ExecuteOnlyRole
GO