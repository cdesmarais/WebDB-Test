if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGenGoogleSiteMapData]') and objectproperty(id, N'isprocedure') = 1)
drop procedure [dbo].[DNGenGoogleSiteMapData]
go

create procedure dbo.DNGenGoogleSiteMapData

as

	set transaction isolation level read uncommitted
	set nocount on;
	
	with			nlurlmax as (
		select		rid,
					max(nldataid) nldataid
		from		nlurlvw
		group by	rid
	)
	select			r.rid, 
					nl.nlurl, 
					dm.publicsite
	from			restaurantvw r
	inner join		nlurlvw nl
	on				r.rid = nl.rid
	inner join		nlurlmax
	on				nlurlmax.nldataid = nl.nldataid
	and				nlurlmax.rid = nl.rid
	inner join		dbo.NeighborhoodAVW n 
	on				n.neighborhoodid = r.neighborhoodid
	and				n.LanguageID = r.LanguageID
	inner join		dbo.ERBRestaurant er
	on				r.RID = er.RID	
	inner join		domain dm
	on				r.domainid = dm.domainid
	inner join		MetroAreaAVW m
	on				n.MetroAreaID = m.MetroAreaID
	and				m.LanguageID = r.LanguageID
	where			r.RestStateID in (1,5,6,7,13,16)
	and				m.Active = 1
	and				m.MetroAreaID != 58
	order by		r.rid

go

grant execute on [DNGenGoogleSiteMapData] to executeonlyrole

go