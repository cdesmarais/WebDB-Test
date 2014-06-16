if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGenGoogleFeed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGenGoogleFeed]
GO

CREATE PROCEDURE dbo.DNGenGoogleFeed

AS
-- Google Primary Query
select		rname,
			r.rid,
			address1,
			coalesce(address2,'') as address2,
			city,
			state,
			zip,
			coalesce(latitude,'-1') as lat,
			coalesce(longitude,'-1') as long,
			n.nbhoodname,
			m.rmdesc as theDescription,
			case when coalesce(i.ImageName,'0') <> '0' then i.ImageName else '' end as RestImageName,
			coalesce(m.hours,'') as hours,
			d.diningstyle,
			coalesce(r.chef,'') as theChef,
			coalesce(r.crossstreet,'') as theCrossSt,
			coalesce(m.publictransit,'') as thePubTransit,
			dc.dresscode,
			coalesce(r.pricequartileid,0) as thePriceQuartileID,
			coalesce(pq.Symbols,'') as thePriceSymbols,
			'' as smoking,
			wo.walkinoption,
			coalesce(mt.mintipsizeoption,'') as theTipPolicy,
			coalesce(m.parkingdescription,'') as theParkingDescription,
			coalesce(pk.parking,'') as parking,
			coalesce(dbo.fFormatPhone(r.phone,cn.countrycode),'') as theResoPhone,
			coalesce(dbo.fFormatPhone(r.Faxphone,cn.countrycode),'') as theFax,
			cn.countryid,
			coalesce(r.externalurl,'') as theExternalURL,
			CASE WHEN ma.DFFStartDT IS NULL THEN 0 ELSE 1 END as DFFEnabled,
			ISNULL(dffStats.totaldffs, -1) as TotalDFFs,
			dm.PublicSite,
			dm.SiteDisplayName
from		restaurantVW r
inner join DBUserDistinctLanguageVW dbu
on r.LanguageID = dbu.LanguageID
inner join	neighborhoodAVW n 
on			r.neighborhoodid = n.neighborhoodid
and			r.LanguageID = n.LanguageID
inner join	RestaurantMessageAVW m 
on			r.rid = m.rid
and			r.LanguageID = m.LanguageID			
left join	restaurantimage i 
on			i.rid=r.rid
LEFT join DFFDailySummaryRIDStatsHolding dffStats
on r.RID = dffStats.WebRID
inner join	diningstyleLocal d 
on			d.diningstyleid=r.diningstyleid
and			d.LanguageID = r.LanguageID
inner join	dresscodeLocal dc 
on			dc.dresscodeid=r.dresscodeid 
and			dc.LanguageID = r.LanguageID
inner join	walkinoptionLocal wo 
on			wo.woid=r.woid 
and			wo.LanguageID = r.LanguageID
left join	mintipsizeoption mt 
on			mt.mintipsizeoptionid=r.mintipsizeoptionid 
inner join	ParkingLocal pk 
on			pk.parkingid=r.parkingid 
and			pk.LanguageID = r.LanguageID
inner join	PriceQuartileVW pq
on			pq.PriceQuartileID = r.PriceQuartileID
and			pq.LanguageID = r.LanguageID
and			pq.CountryID = r.Country 
inner join	countryAVW cn 
on			cn.countryid=r.country 
and			cn.LanguageID = r.LanguageID
inner join	metroareaAVW ma 
on			ma.metroareaid=n.metroareaid
and			ma.LanguageID = r.LanguageID
inner join Domain dm
on r.DomainID = dm.DomainID
where		ma.MetroAreaID not in (1, 58) -- Always exlcude Exlusive and Demoland
and			r.RestStateID = 1 
and			ma.active = 1 

-- get food type list..
select		t.foodtype,
			ft.rid 
from		foodtypes ft
inner join	restaurantVW r
on			ft.rid = r.rid
inner join	foodtype t 
on			ft.foodtypeid=t.foodtypeid 
and			r.LanguageID = t.LanguageID
order by	ft.rid asc,isprimary desc

-- get payment types.
select		t.paymenttype,
			pt.rid 
from		paymenttypes pt
inner join	restaurantVW r
on			pt.rid = r.rid
inner join	paymenttypeLocal t 
on			pt.paymenttypeid=t.paymenttypeid 
and			r.LanguageId = t.LanguageID
order by	pt.rid asc

-- get offer association..
select		o.offer,
			os.rid 
from		offers os
inner join	restaurantVW r
on			os.rid = r.rid
inner join	offerLocal o 
on			os.offerid=o.offerid 
and			r.LanguageID = o.LanguageID
order by	os.rid asc

--Get configuration values for Google feed.
Select LKey, ValueInt, ValueChar from ValueLookup
WHERE LType = 'GOOGLEEXTRACT'

--get top 3 topten metro lists for restaurants  
exec procGetDCListsForReportFeed  

GO


GRANT EXECUTE ON [DNGenGoogleFeed] TO ExecuteOnlyRole

GO