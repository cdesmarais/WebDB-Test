if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_GetRests_All]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_GetRests_All]
GO






CREATE PROCEDURE dbo.Admin_Promos_Pages_GetRests_All
(
  @MetroArea int,
  @PromoID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select r.RID as Restaurant_ID
,r.Rname as restname
,MetroArea.MetroAreaName as metroarea
,PriceQuartileID,FoodType.Value as food
,COALESCE(PromoRests.PromoID,0) as promo
,COALESCE(PromoRests.Message,'') as promo_message
,COALESCE(PromoRests.short_desc,'') as short
,n.NbhoodName as neighborhood_name
,COALESCE(Promo_Rests.Reserve,'') as Reserve,COALESCE(Rank,999) as Rank,scheduleID as Schedule_ID,lunch,dinner,r.RestStateID AS RestaurantState
from		Restaurant r
left outer join PromoRests 
on r.RID = PromoRests.RID and PromoRests.PromoID = @PromoID
left outer join Promo_Rests_Days
on PromoRests.RID = PromoRestsDays.RID and PromoRestsDays.PromoID = @PromoID
inner join Neighborhood n 
on r.neighborhoodid = n.neighborhoodid
inner Join MetroArea 
on n.metroareaid = MetroArea.metroareaid
INNER JOIN FoodTypes 
ON r.RID = FoodTypes.RID and FoodTypes.IsPrimary = 1
INNER JOIN FoodType 
ON FoodTypes.foodtypeID = FoodType.foodtypeID
where MetroArea.metroareaid = @MetroArea 
and (r.RestStateID <> 4) AND (r.RestStateID <> 3) AND (r.RestStateID <> 2) AND (r.RestStateID <> 8) 

order by rank,restname,scheduleID
GO

GRANT EXECUTE ON [Admin_Promos_Pages_GetRests_All] TO ExecuteOnlyRole

GO
