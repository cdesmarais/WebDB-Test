if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllDomains]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllDomains]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllDomains
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT
	d.DomainID,
	d.Domain,
	d.SiteDisplayName,
	d.PublicSite,
	d.SecureSite,
	d.ExportSite,
	d.Active,
	d.PrimaryLanguageID,
	d.PrimaryCountryID,
	d.DefaultPage,
	d.GoogleMapsApiUrl,
	d.SupportSite,
	d.ConciergeSite,
	d.GoogleMapsAPIKey,
	l.LanguageCode as PrimaryLanguageCode
FROM	Domain d
INNER JOIN Language l 
	on l.LanguageID = d.PrimaryLanguageID

GO

GRANT EXECUTE ON [RestaurantImporter_GetAllDomains] TO ExecuteOnlyRole

GO

