if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Monthly_Restaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Monthly_Restaurants]
GO

CREATE PROCEDURE dbo.Report_Monthly_Restaurants
(
	@Month datetime
)

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select r.RID as [Restaurant ID], r.Rname as Name, ma.MetroAreaName as [Metro Area], n.nbhoodname as Neighborhood, 
		OTFood.FoodType as [Food Type],OTPrice.pricequartile as Price,
		count(res.resID) as Reservations, 
		sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers, 
		sum(cast(firstTime as int)) as [First time]
from		restaurantVW r
inner join	reservation res 
on			r.RID = res.RID
inner join	neighborhoodAVW n 
on			r.neighborhoodID = n.neighborhoodID
and			r.LanguageID = n.LanguageID
inner join	MetroareaAVW ma 
on			n.MetroareaID = ma.MetroareaID
and			r.LanguageID = ma.LanguageID
inner join	foodtypes OTFoods 
on			r.RID = OTFoods.RID 
and			isprimary = 1
inner join	foodtype OTFood 
on			OTFoods.foodtypeid = OTFood.foodtypeid
and			OTFood.LanguageID = r.LanguageID
INNER JOIN	PriceQuartileAVW OTPrice
ON			r.PriceQuartileID=OTPrice.PriceQuartileID 
AND			r.Country = OTPrice.CountryID
and			r.LanguageID = OTPrice.LanguageID
where		RStateID not in (3,4,8,9,10) and DATEDIFF(mm, @Month, shiftDate) = 0
and			n.MetroareaID <> 1
group by r.RID, r.Rname, ma.MetroAreaname, n.nbhoodname, OTFood.FoodType,OTPrice.pricequartile
order by r.RID
GO




GRANT EXECUTE ON [Report_Monthly_Restaurants] TO ExecuteOnlyRole

GO
