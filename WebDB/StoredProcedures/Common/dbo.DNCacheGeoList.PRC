if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheGeoList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheGeoList]
GO

create procedure dbo.DNCacheGeoList
as
set nocount on
set transaction isolation level read uncommitted

declare @TempPDCountByMetro table (MetroAreaID int, PDRestaurantCount int)
declare @TempMetroFeatured table (MetroAreaID int, IsFeatured bit)
declare @TempMetroFeaturedMobile table (MetroAreaID int, IsMobileFeatured bit)

-- Counting the number of restaurants with private dining published in each metro
insert into @TempPDCountByMetro 
select m.MetroAreaID, COUNT(r.RID)
	from MetroArea m
	left outer join Neighborhood n on n.MetroAreaID = m.MetroAreaID
	left outer join Restaurant r on n.NeighborhoodID = r.NeighborhoodID and r.PublishPrivateDining = 1
	group by m.MetroAreaID

--Determine which metros are featured on the site and on mobile.
--These temp tables are used to guarantee MetroAreaID uniqueness 
--for metros that are "IsFeatured" and "IsMobileFeatured"
insert into @TempMetroFeatured
	select		distinct MetroAreaID, IsFeatured
	from 		StateAreaListing
	where		IsFeatured = 1
	
insert into @TempMetroFeaturedMobile
	select		distinct MetroAreaID, IsMobileFeatured
	from		StateAreaListing
	where		IsMobileFeatured = 1	

--The first set in the union contains the metros that belong
--strictly to the domain by supported domain and language.
select  
			m.metroareaid AS GeoID 
			,m.MetroAreaName AS GeoName
			,SearchLevel
			,ServerToLocalOffset as TimeZoneOffset
			,m.Active
			,m.CountryID
			,Message
			,TitleTag 
			,ShortDisplayName
			,_OffsetMi as TimeZoneOffSetfromGMT
			,c.DateFormat
			,l.LanguageCode
			,MetaDescriptionText
			,MetaKeywordText
			,PublicSite
			,m.SupportedDomainID
			,CASE WHEN (LEN(LTRIM(m.MetroAreaSName)) = 0) THEN m.MetroAreaName ELSE m.MetroAreaSName END SName
			,m.MetroCenterLat
			,m.MetroCenterLon
			,isnull(m.MetroDetectionPointLat, m.MetroCenterLat) MetroDetectionPointLat
			,isnull(m.MetroDetectionPointLon,m.MetroCenterLon) MetroDetectionPointLon
			,c.IsDistanceinMiles			
			,isnull(csr.Radius, -1) as BubbleUpDistance
			,isnull(csrd.Radius, -1) as CountrySearchRadiusDefault
			,m.ShowRegionLists
			,m.MetroTitleTag
			,m.MetroLatSpan
			,m.MetroLonSpan
			,m.PDIntroHeader
			,m.PDIntro
			,PDRestCount.PDRestaurantCount as PDRestaurantCount
			,m.ShowSpotlight
			,m.SpotlightLink
			,m.SpotlightLinkText
			,m.SpotlightImage
			,m.TZID
			,isnull(tf.IsFeatured,0) IsFeatured
			,isnull(tfm.IsMobileFeatured,0) IsMobileFeatured
from		MetroAreaVW m
inner join	Language l
on			l.LanguageID = m.LanguageID
inner join	TimeZoneVW t 
on			(t.TZID = m.TZID) 
inner join	Country c
on			m.CountryID = c.CountryID
inner join 	[Domain] d 
on 			m.[SupportedDomainID] = d.[DomainID]
inner join	DBUser du
on			m.SupportedDomainID = isnull(du.DomainID,m.SupportedDomainID)
and			du.DBUser = user
left join	(
	select		CountrySearchRadiusLookup.CountryID, 
				CountrySearchRadiusLookup.IsBubbleUpDistance, 
				max(CountrySearchRadiusLookup.Radius) as Radius
	from		CountrySearchRadiusLookup
	where		CountrySearchRadiusLookup.IsBubbleUpDistance=1
	group by	CountrySearchRadiusLookup.CountryID, CountrySearchRadiusLookup.IsBubbleUpDistance
) csr
on			m.CountryID = csr.CountryID
and			csr.IsBubbleUpDistance = 1
left join 	CountrySearchRadiusLookup csrd
on 			c.CountryID = csrd.CountryID
and 		csrd.IsDefaultSearchRadius = 1
inner join	@TempPDCountByMetro PDRestCount
on			PDRestCount.MetroAreaID = m.MetroAreaID
left join	@TempMetroFeatured tf
on			m.MetroAreaID = tf.MetroAreaID
left join	@TempMetroFeaturedMobile tfm
on			m.MetroAreaID = tfm.MetroAreaID
where		m.Active = 1
and			m.SupportedDomainID != 0
union all
--second set gets all metros that are supported by the user's domain
--but don't match the user's db language or optional language
select  
			m.metroareaid AS GeoID
			,m.MetroAreaName AS GeoName
			,SearchLevel
			,ServerToLocalOffset as TimeZoneOffset
			,m.Active
			,m.CountryID
			,Message
			,TitleTag
			,ShortDisplayName
			,_OffsetMi as TimeZoneOffSetfromGMT
			,c.DateFormat
			,l.LanguageCode
			,MetaDescriptionText
			,MetaKeywordText
			,PublicSite
			,m.SupportedDomainID
			,CASE WHEN (LEN(LTRIM(m.MetroAreaSName)) = 0) THEN m.MetroAreaName ELSE m.MetroAreaSName END SName
			,m.MetroCenterLat
			,m.MetroCenterLon
			,isnull(m.MetroDetectionPointLat, m.MetroCenterLat) MetroDetectionPointLat
			,isnull(m.MetroDetectionPointLon,m.MetroCenterLon) MetroDetectionPointLon
			,c.IsDistanceinMiles
			,isnull(csr.Radius, -1) as BubbleUpDistance
			,isnull(csrd.Radius, -1) as CountrySearchRadiusDefault
			,m.ShowRegionLists
			,m.MetroTitleTag
			,m.MetroLatSpan
			,m.MetroLonSpan
			,m.PDIntroHeader
			,m.PDIntro
			,PDRestCount.PDRestaurantCount as PDRestaurantCount
			,m.ShowSpotlight
			,m.SpotlightLink
			,m.SpotlightLinkText
			,m.SpotlightImage
			,m.TZID
			,isnull(tf.IsFeatured,0) IsFeatured
			,isnull(tfm.IsMobileFeatured,0) IsMobileFeatured
from		MetroAreaAVW m
inner join	Language l
on			l.LanguageID = m.LanguageID
inner join	TimeZoneVW t 
on			(t.TZID = m.TZID) 
inner join	Country c
on			m.CountryID = c.CountryID
inner join 	[Domain] d 
on 			m.[SupportedDomainID] = d.[DomainID]
inner join	DBUser du
on			m.SupportedDomainID = isnull(du.DomainID,m.SupportedDomainID)
and			du.DBUser = user
left join	(
	select		CountrySearchRadiusLookup.CountryID, 
				CountrySearchRadiusLookup.IsBubbleUpDistance, 
				max(CountrySearchRadiusLookup.Radius) as Radius
	from		CountrySearchRadiusLookup
	where		CountrySearchRadiusLookup.IsBubbleUpDistance=1
	group by	CountrySearchRadiusLookup.CountryID, CountrySearchRadiusLookup.IsBubbleUpDistance
) csr
on			m.CountryID = csr.CountryID
and			csr.IsBubbleUpDistance = 1
left join 	CountrySearchRadiusLookup csrd
on 			c.CountryID = csrd.CountryID
and 		csrd.IsDefaultSearchRadius = 1
inner join @TempPDCountByMetro PDRestCount
on			PDRestCount.MetroAreaID = m.MetroAreaID
left join	@TempMetroFeatured tf
on			m.MetroAreaID = tf.MetroAreaID
left join	@TempMetroFeaturedMobile tfm
on			m.MetroAreaID = tfm.MetroAreaID
where		m.[LanguageID] = d.[PrimaryLanguageID]
and			m.Active = 1
and			m.MetroAreaID not in (Select MetroAreaID from MetroAreaVW)
and			m.SupportedDomainID != 0
union all
--This set contains the metros that have SupportedDomainId = 0 (Demoland..)
select  
			m.metroareaid AS GeoID 
			,m.MetroAreaName AS GeoName
			,SearchLevel
			,ServerToLocalOffset as TimeZoneOffset
			,m.Active
			,m.CountryID
			,Message
			,TitleTag 
			,ShortDisplayName
			,_OffsetMi as TimeZoneOffSetfromGMT
			,c.DateFormat
			,l.LanguageCode
			,MetaDescriptionText
			,MetaKeywordText
			,PublicSite
			,m.SupportedDomainID
			,CASE WHEN (LEN(LTRIM(m.MetroAreaSName)) = 0) THEN m.MetroAreaName ELSE m.MetroAreaSName END SName
			,m.MetroCenterLat
			,m.MetroCenterLon
			,isnull(m.MetroDetectionPointLat, m.MetroCenterLat) MetroDetectionPointLat
			,isnull(m.MetroDetectionPointLon,m.MetroCenterLon) MetroDetectionPointLon
			,c.IsDistanceinMiles			
			,isnull(csr.Radius, -1) as BubbleUpDistance
			,isnull(csrd.Radius, -1) as CountrySearchRadiusDefault
			,m.ShowRegionLists
			,m.MetroTitleTag
			,m.MetroLatSpan
			,m.MetroLonSpan
			,m.PDIntroHeader
			,m.PDIntro
			,PDRestCount.PDRestaurantCount as PDRestaurantCount
			,m.ShowSpotlight
			,m.SpotlightLink
			,m.SpotlightLinkText
			,m.SpotlightImage
			,m.TZID
			,isnull(tf.IsFeatured,0) IsFeatured
			,isnull(tfm.IsMobileFeatured,0) IsMobileFeatured
from		MetroAreaAVW m
inner join	Language l
on			l.LanguageID = m.LanguageID
inner join	TimeZoneVW t 
on			(t.TZID = m.TZID) 
inner join	Country c
on			m.CountryID = c.CountryID
inner join 	[Domain] d 
on 			m.[SupportedDomainID] = d.[DomainID]
inner join	DBUserDistinctLanguageVW duw
on			m.LanguageID = duw.LanguageID
left join	(
	select		CountrySearchRadiusLookup.CountryID, 
				CountrySearchRadiusLookup.IsBubbleUpDistance, 
				max(CountrySearchRadiusLookup.Radius) as Radius
	from		CountrySearchRadiusLookup
	where		CountrySearchRadiusLookup.IsBubbleUpDistance=1
	group by	CountrySearchRadiusLookup.CountryID, CountrySearchRadiusLookup.IsBubbleUpDistance
) csr
on			m.CountryID = csr.CountryID
and			csr.IsBubbleUpDistance = 1
left join 	CountrySearchRadiusLookup csrd
on 			c.CountryID = csrd.CountryID
and 		csrd.IsDefaultSearchRadius = 1
inner join	@TempPDCountByMetro PDRestCount
on			PDRestCount.MetroAreaID = m.MetroAreaID
left join	@TempMetroFeatured tf
on			m.MetroAreaID = tf.MetroAreaID
left join	@TempMetroFeaturedMobile tfm
on			m.MetroAreaID = tfm.MetroAreaID
where		(m.Active = 1 or (m.MetroAreaID = 1))
and			m.SupportedDomainID = 0
order by	SName

go


grant execute on [DNCacheGeoList] to ExecuteOnlyRole

GO

