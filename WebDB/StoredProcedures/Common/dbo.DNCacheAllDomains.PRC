if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheAllDomains]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheAllDomains]
GO

CREATE Procedure dbo.DNCacheAllDomains
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

-- WE ONLY WANT 1 OF THE PERHAPS MANY OPENTABLE.COM DOMAINS, SO SELECT IT SEPARATELY

(	
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
	INNER JOIN Language l on l.LanguageID = d.PrimaryLanguageID
	WHERE	DomainID = 1
)
UNION
(
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
	INNER JOIN Language l on l.LanguageID = d.PrimaryLanguageID
	WHERE	Domain <> 'opentable.com' and DomainID <> 0
)

GO

GRANT EXECUTE ON [DNCacheAllDomains] TO ExecuteOnlyRole

GO

