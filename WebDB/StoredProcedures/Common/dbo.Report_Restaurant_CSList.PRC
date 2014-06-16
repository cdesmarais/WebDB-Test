if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_CSList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_CSList]
GO

CREATE PROCEDURE dbo.Report_Restaurant_CSList

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select 
		rt.RID
		,rt.RName as RestName
		,OTPrice.PriceQuartileID as Price
		,coalesce(rt.ExternalURL,'')
		,OTFoods.FoodTypeID as FoodType
		,rt.Address1
		,rt.city
		,rt.state
		,rt.ZIP
		,rt.Phone
From		RestaurantVW rt
inner join	Neighborhood n 
on			rt.NeighborhoodID = n.NeighborhoodID
inner join	MetroArea ma 
on			n.MetroAreaID = ma.MetroAreaID
INNER JOIN	PriceQuartileAVW OTPrice
ON			rt.PriceQuartileID=OTPrice.PriceQuartileID 
AND			rt.Country = OTPrice.CountryID
and			rt.LanguageID = OTPrice.LanguageID
inner join	FoodTypes OTFoods 
on			rt.RID = OTFoods.RID
inner join	FoodType OTFood 
on			OTFoods.FoodTypeID = OTFood.FoodTypeID
and			rt.LanguageID = OTFood.LanguageID
Where		ma.MetroAreaID <> 1
and			(rt.RestStateID = 1)
and			OTFoods.IsPrimary = 1
Order by rt.RName
 
GO


GRANT EXECUTE ON [Report_Restaurant_CSList] TO ExecuteOnlyRole

GO
