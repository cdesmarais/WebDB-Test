if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFGetTopTenList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFGetTopTenList]
GO

CREATE PROCEDURE dbo.DFFGetTopTenList(
	@parMetroID int
)

AS

set transaction isolation level read committed

-- get the topten list for a specific metroid. This proc is being called from the DFF thank you page
select 
	'<a href=''' + 'http://' +  d.publicsite + '/rest_profile.aspx?ref=1120&rid=' + cast(r.rid as varchar) + '''>'
	+ r.RName + '</a>' as RestaurantName,
	
	n.nbhoodname as NbHood,		
	p.Symbols as PrcQuartile,
	ft.FoodType as Cuisine
from 
	RestaurantVW r		 
	
	inner join RestaurantTopList rtl
		on r.RID = rtl.RID
		
	inner join NeighborhoodVW n 
	on (n.neighborhoodid=r.neighborhoodid and n.metroareaid=@parMetroID)

	inner join PriceQuartileVW p 
	on ((Case when(r.PriceQuartileID=5) then 0 else r.PriceQuartileID end)=p.pricequartileid and p.CountryID = r.Country)

	inner join Domain d 
	on d.domainid = r.domainid

	inner join FoodTypes fts
		ON (r.RID = fts.RID and fts.IsPrimary=1)

	inner join FoodType ft
		ON (ft.FoodTypeID = fts.foodtypeid and ft.LanguageID = r.LanguageID)
		
	where	rank <= 10
	and		r.reststateid !=4
	order by rank

GO

GRANT EXECUTE ON [DFFGetTopTenList] TO ExecuteOnlyRole

GO
