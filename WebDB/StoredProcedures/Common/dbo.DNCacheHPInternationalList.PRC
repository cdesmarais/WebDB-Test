
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheHPInternationalList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheHPInternationalList]
GO


CREATE PROCEDURE dbo.DNCacheHPInternationalList
 As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select AreaSection as StateName, MacroID, MetroAreaID, ShortName as FeaturedName, coalesce(AreaSection, ShortName) as AreaSection, 
(select count(AreaSection) from StateAreaListing where AreaSection = sal.AreaSection) as dropcount, CountryID as StateID, sal.DomainID, d.PublicSite as PublicSite, d.DefaultPage as DefaultPage, sal.NLURL 
from StateAreaListing sal
INNER JOIN Domain d ON sal.DomainID = d.DomainID
where isFeatured is null and CountryID <> 'US' and sal.active = 1
order by AreaSection, ShortName
GO

GRANT EXECUTE ON [DNCacheHPInternationalList] TO ExecuteOnlyRole

GO
