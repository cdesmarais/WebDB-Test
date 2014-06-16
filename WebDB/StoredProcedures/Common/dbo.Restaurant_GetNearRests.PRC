if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetNearRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetNearRests]
GO

CREATE Procedure dbo.Restaurant_GetNearRests
 (
  @Latitude dec(10,6),
  @Longitude dec(10,6),
  @Distance int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--Declare @Longitude dec(10,6),@Latitude dec(10,6), 
Declare @rad_convert dec(20,16), @pi dec(20,16)

Set @pi = PI()
Set @rad_convert = (@pi / 180)

--Select @Latitude = Latitude,@Longitude = Longitude from Restaurant where RID = @RID
select  *
from (
	Select r.RID as restaurant_ID
	,r.RName as RestaurantName
	,MetroAreaID as Metro_Area_ID,n.NbhoodName as NeighborhoodName
	,PriceQuartileID as Price_Quartile_ID
	,ft.FoodType as FoodType
	,RestStateID as Restaurant_State_ID
	,	(atan(-(sin(Latitude*@rad_convert) * sin(@Latitude*@rad_convert) + (cos(Latitude*@rad_convert) * cos(@Latitude*@rad_convert) * cos(Longitude*@rad_convert - @Longitude*@rad_convert)))/sqrt(-(sin(Latitude*@rad_convert) * sin(@Latitude*@rad_convert) + (cos(Latitude*@rad_convert) * cos(@Latitude*@rad_convert) * cos(Longitude*@rad_convert - @Longitude*@rad_convert))) * (sin(Latitude*@rad_convert) * sin(@Latitude*@rad_convert) + (cos(Latitude*@rad_convert) * cos(@Latitude*@rad_convert) * cos(Longitude*@rad_convert - @Longitude*@rad_convert))) +1)) + 2 * atan(1))* 3437.74677 * 1.1508 * 5.2800102998e+3 
	AS Distance
	from		RestaurantVW r
	inner join	NeighborhoodAVW n 
	on			r.NeighborhoodID = n.NeighborhoodID
	and			r.LanguageID = n.LanguageID
	inner join	FoodTypes 
	on			r.RID = FoodTypes.RID 
	and			IsPrimary = 1
	inner join	FoodType ft
	on			FoodTypes.FoodTypeID = ft.FoodTypeID
	and			ft.LanguageId = r.LanguageID
	where RestStateID = 1 
	and IsReachable = 1
	and Latitude is not null 
	and Longitude is not null 
	and (Latitude <> @Latitude AND @Longitude <> Longitude)
	and ((atan(-(sin(Latitude*@rad_convert) * sin(@Latitude*@rad_convert) + (cos(Latitude*@rad_convert) * cos(@Latitude*@rad_convert) * cos(Longitude*@rad_convert - @Longitude*@rad_convert)))/sqrt(-(sin(Latitude*@rad_convert) * sin(@Latitude*@rad_convert) + (cos(Latitude*@rad_convert) * cos(@Latitude*@rad_convert) * cos(Longitude*@rad_convert - @Longitude*@rad_convert))) * (sin(Latitude*@rad_convert) * sin(@Latitude*@rad_convert) + (cos(Latitude*@rad_convert) * cos(@Latitude*@rad_convert) * cos(Longitude*@rad_convert - @Longitude*@rad_convert))) +1)) + 2 * atan(1))* 3437.74677 * 1.1508 * 5.2800102998e+3) < @Distance
union
	Select r.RID as restaurant_ID
	,r.RName as RestaurantName
	,MetroAreaID as Metro_Area_ID
	,n.NbhoodName as NeighborhoodName
	,PriceQuartileID as Price_Quartile_ID
	,ft.FoodType as FoodType
	,RestStateID as Restaurant_State_ID
	,0 AS Distance
	from		RestaurantVW r
	inner join	NeighborhoodAVW n 
	on			r.NeighborhoodID = n.NeighborhoodID
	and			r.LanguageID = r.LanguageID
	inner join	FoodTypes 
	on			r.RID = FoodTypes.RID 
	and			IsPrimary = 1
	inner join FoodType ft
	on			FoodTypes.FoodTypeID = ft.FoodTypeID
	and			r.LanguageID = ft.LanguageID
	where RestStateID = 1 
	and IsReachable = 1
	and Latitude = @Latitude 
	AND @Longitude = Longitude 
	and Latitude is not null 
	and Longitude is not null

) as tempdb1
order by distance
GO

GRANT EXECUTE ON [Restaurant_GetNearRests] TO ExecuteOnlyRole

GO
