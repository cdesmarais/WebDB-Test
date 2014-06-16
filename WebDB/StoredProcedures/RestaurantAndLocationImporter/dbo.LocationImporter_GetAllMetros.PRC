if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LocationImporter_GetAllMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LocationImporter_GetAllMetros]
GO

create procedure dbo.LocationImporter_GetAllMetros
as
set nocount on
set transaction isolation level read uncommitted

declare @TempPDCountByMetro table (MetroAreaID int, PDRestaurantCount int)

-- Counting the number of restaurants with private dining published in each metro
insert into @TempPDCountByMetro 
select m.MetroAreaID, COUNT(r.RID)
	from MetroArea m
	left outer join Neighborhood n on n.MetroAreaID = m.MetroAreaID
	left outer join Restaurant r on n.NeighborhoodID = r.NeighborhoodID and r.PublishPrivateDining = 1
	group by m.MetroAreaID

select  
	 m.metroareaid AS GeoID 
	,m.MetroAreaName AS GeoName
	,m.MetroAreaSName As SortableName
	,m.ShortDisplayName
	,m.TitleTag
	,m.MetaKeywordText
	,m.MetaDescriptionText
	,_OffsetMi as TimeZoneOffSetfromGMT
	,m.SupportedDomainID
	,m.CountryID
	,m.MetroCenterLat
	,m.MetroCenterLon
	,m.TZID
	,t.TZName
	,t.Code as TZCode
	,m.LanguageID
	,CASE   
       WHEN COALESCE(pl.promolinktypeid, 0) > 0 THEN 1  
       ELSE 0  
     END as HasLimoService
    ,m.Active
    ,m.PDIntro
    ,m.PDIntroHeader
    ,PDRestCount.PDRestaurantCount as PDRestaurantCount
from		MetroAreaAVW m
inner join	TimeZoneVW t 
on			(t.TZID = m.TZID) 
inner join	@TempPDCountByMetro PDRestCount
on			PDRestCount.MetroAreaID = m.MetroAreaID
-- magic value lookup for Limo service malarky
left outer join PromoLinkToID plid
    on plid.ValueID = m.MetroAreaID
left outer join dbo.promolink pl 
	on pl.promolinkid = plid.promolinkid    
	AND pl.promolinktypeid = 1 -- 1: Limo 
-- abracadabra motherfucker

go

grant execute on [LocationImporter_GetAllMetros] to ExecuteOnlyRole

GO

