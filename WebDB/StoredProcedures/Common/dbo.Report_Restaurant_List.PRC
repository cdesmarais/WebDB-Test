if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_List]
GO

CREATE PROCEDURE dbo.Report_Restaurant_List

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select ma.MetroAreaName as MetroName
			,rt.RName as RestName
			,OTPrice.PriceQuartile as Price
			,rt.ExternalURL
			,n.NbhoodName as Neighborhood
			,OTFood.FoodType as FoodType
			,rt.Address1
			,rt.city
			,rt.state
			,rt.ZIP
			,rt.phone
			,rt.RID
			,rt.ReserveCode
			,rtMess.RMDesc
From		restaurantVW rt
inner join	neighborhoodAVW n 
on			rt.NeighborhoodID = n.NeighborhoodID
and			rt.LanguageID = n.LanguageID
inner join	MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			rt.LanguageID = ma.LanguageID
INNER JOIN	PriceQuartileAVW OTPrice
ON			rt.PriceQuartileID=OTPrice.PriceQuartileID 
AND			rt.Country = OTPrice.CountryID
and			rt.LanguageID = OTPrice.LanguageID
inner join	RestaurantMessageAVW rtMess 
on			rt.RID = rtMess.RID
and			rt.LanguageID = rtMEss.LanguageID
inner join FoodTypes OTFoods 
on			rt.RID = OTFoods.RID
inner join	FoodType OTFood 
on			OTFoods.FoodTypeID = OTFood.FoodTypeID
and			OTFood.LanguageID = rt.LanguageID
Where		ma.MetroAreaID <> 1
and			rt.RestStateID in (1, 5, 6, 7, 8, 9, 13, 16) 
and			OTFoods.IsPrimary = 1
Order by	ma.MetroAreaName
			,rt.RName

GO


GRANT EXECUTE ON [Report_Restaurant_List] TO ExecuteOnlyRole

GO
