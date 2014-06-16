if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SCRT_Report_Monthly_Reservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SCRT_Report_Monthly_Reservations]
GO

CREATE PROCEDURE dbo.SCRT_Report_Monthly_Reservations
(
  @thrudate Datetime = Null
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

If @thrudate is null
Begin
	Select @thrudate = getdate() --get request(current) date to range
End


Select 
			rest.RID
			,rest.RName
			,ma.MetroAreaName
			,n.NbhoodName
			,OTFood.FoodType as Value
			,OTPrice.PriceQuartile as Value
			,count(ResID) as Resos
			,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers
			,sum(cast(FirstTime as int)) as  FirstTime
from		Reservation res
inner join	RestaurantVW rest 
on			res.RID = rest.RID
inner join	NeighborhoodAVW n 
on			rest.NeighborhoodID = n.NeighborhoodID
and			rest.LanguageID = n.LanguageID
inner join	MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			rest.LanguageID = ma.LanguageID
inner join	FoodTypes OTFoods 
on			rest.RID = OTFoods.RID
inner join	FoodType OTFood 
on			OTFoods.FoodTypeID = OTFood.FoodTypeID
and			rest.LanguageID = OTFood.LanguageID
INNER JOIN	PriceQuartileAVW OTPrice
ON			rest.PriceQuartileID=OTPrice.PriceQuartileID 
and			rest.LanguageID = OTPrice.LanguageID
AND			rest.Country = OTPrice.CountryID
where DATEDIFF(mm, @thrudate, ShiftDate) = 0 
and RStateID not in (3,4,8,9,10) 
and OTFoods.IsPrimary = 1
group by rest.RID
,rest.RName
,ma.MetroAreaName
,n.NbhoodName
,OTFood.FoodType
,OTPrice.PriceQuartile
order by rest.RID
 
GO


GRANT EXECUTE ON [SCRT_Report_Monthly_Reservations] TO ExecuteOnlyRole

GO
