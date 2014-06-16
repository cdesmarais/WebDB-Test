if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_HomePageInternationalList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_HomePageInternationalList]
GO


CREATE PROCEDURE dbo.Admin_HomePageInternationalList (@CountryID nchar(2))
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		AreaSection as StateName
		,MacroID
		,MetroAreaID
		,ShortName as FeaturedName
		,coalesce(AreaSection, ShortName) as AreaSection		
		,CountryID as StateID
		,sal.DomainID		
		,sal.AreaID
		,sal.IsFeatured		
from		StateAreaListing sal
INNER JOIN	Domain d 
ON		sal.DomainID = d.DomainID
where		IsNull(StateID, '') = ''
		and sal.active = 1
		and countryID <> 'US'
		and countryID = @CountryID
		and sal.DomainID = 1
order by	sal.IsFeatured desc, sal.AreaSection asc, FeaturedName asc
GO

GRANT EXECUTE ON [Admin_HomePageInternationalList] TO ExecuteOnlyRole

GO
