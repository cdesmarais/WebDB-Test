
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheHPFeaturedMetrosList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheHPFeaturedMetrosList]
GO


CREATE PROCEDURE dbo.DNCacheHPFeaturedMetrosList
 As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select			StateAreaListing.MacroID, 
				StateAreaListing.MetroAreaID, 
				coalesce(ShortName,macroName, MetroAreaName) as FeaturedName, 
				COALESCE(ShortDisplayName, MetroAreaName) AS seoname,
				showonfooter,
				ma.LanguageID,
				d.DefaultPage,
				d.PublicSite,
				StateAreaListing.NLURL
from			StateAreaListing
INNER JOIN		Domain d 
ON				StateAreaListing.DomainID = d.DomainID  
left outer join MetroareaVW ma 
on				StateAreaListing.MetroAreaID = ma.MetroAreaID
left outer join macroneighborhoodVW mn 
on				StateAreaListing.MacroID = mn.MacroID
where			isFeatured = 1 
and				StateAreaListing.active = 1 
order by		FeaturedName
GO

GRANT EXECUTE ON [DNCacheHPFeaturedMetrosList] TO ExecuteOnlyRole

GO