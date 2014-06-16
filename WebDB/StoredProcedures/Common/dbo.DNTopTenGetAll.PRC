if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNTopTenGetAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNTopTenGetAll]
GO

CREATE PROCEDURE dbo.DNTopTenGetAll

AS

set transaction isolation level read uncommitted

Select r.RID as Restaurant_ID
	,r.RName as restname
	,r.NewFlag
	,ma.MetroAreaName As metroname
	,r.allotment
	,rtl.Rank
	,n.NbhoodName as NeighborhoodName
	,ft.FoodType as food
	,(Case when(PriceQuartileID=5) then 0 else PriceQuartileID end) As PriceQuartileID
	,ma.MetroAreaID
	,r.country
From RestaurantVW r
inner join NeighborhoodAVW n 
		on	r.neighborhoodid = n.neighborhoodid
		and n.LanguageID = r.LanguageID
inner join MetroAreaLocal ma
		on n.metroareaid = ma.metroareaid
		and r.LanguageID = ma.LanguageID
inner join RestaurantTopList rtl
		on r.RID = rtl.RID
INNER JOIN FoodTypes fts
		ON r.RID = fts.RID 
		and fts.IsPrimary = 1
INNER JOIN FoodType ft
		ON fts.foodtypeID = ft.foodtypeID
		and r.LanguageID = ft.LanguageID
where	rank <= 10
and		reststateid !=4
order by ma.MetroAreaID
		,Rank

GO

GRANT EXECUTE ON [DNTopTenGetAll] TO ExecuteOnlyRole

GO
