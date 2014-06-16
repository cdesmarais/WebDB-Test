if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetNewByMetroAreaID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetNewByMetroAreaID]
GO

CREATE Procedure dbo.Restaurant_GetNewByMetroAreaID
(
  @metroid int,
  @newflg int = 0,
  @RestaurantID int = 0
)

AS

set transaction isolation level read uncommitted

Declare @newflgv nvarchar(1)
,@RestID nvarchar(5) 
if @newflg = 0 SELECT @newflgv = '1'
if @newflg > 0 SELECT @newflgv = @newflg
if @RestaurantID = 0 SELECT @RestID = ''
if @RestaurantID > 0 SELECT @RestID = @RestaurantID

if exists 
	( 
		Select		r.RID
		From		Restaurant r
		Inner Join	Neighborhood n 
		On			r.NeighborhoodID = n.NeighborhoodID
		Inner Join	MetroArea ma
		On			n.MetroAreaID = ma.MetroAreaID
		Inner Join	ERBRestaurant 
		ON			r.RID = ERBRestaurant.RID
		Where		ma.MetroAreaID = @metroid
		And			(LEN(@newflgv) = 0 OR CHARINDEX(',' + CAST(NewFlag AS nvarchar(1)) + ',',',' + @newflgv + ',') > 0)
		And			(LEN(@RestID) = 0 OR CHARINDEX(',' + CAST(r.RID AS nvarchar(5)) + ',',',' + @RestID + ',') > 0 And Allotment = 0)
		And			r.RestStateID = 1
	) and ((Select toptenlist From MetroArea Where MetroAreaID = @metroid) = 0 or @newflg = 1) 

BEGIN
	Select top 10 
				r.RID as Restaurant_ID
				,r.RName as restname
				,r.NewFlag
				,ma.MetroAreaName As metroname
				,coalesce(ERBBuild,'0') As ERBBuild
				,allotment,rank = ''
				,n.NbhoodName as NeighborhoodName
				,FoodType.FoodType as food
				,PriceQuartileID
	From		RestaurantVW r
	Inner Join	NeighborhoodAVW n 
	On			n.NeighborhoodID = r.NeighborhoodID
	and			n.LanguageID = r.LanguageID
	Inner Join	MetroAreaAVW ma
	On			ma.MetroAreaID = n.MetroAreaID
	and			ma.LanguageID = r.LanguageID
	Inner Join	ERBRestaurant 
	ON			r.RID = ERBRestaurant.RID
	INNER JOIN	FoodTypes
	ON			r.RID = FoodTypes.RID 
	and			FoodTypes.IsPrimary = 1
	INNER JOIN	FoodType 
	ON			FoodTypes.FoodTypeID = FoodType.FoodTypeID
	AND			FoodType.LanguageID = r.LanguageID
	Where		ma.MetroAreaID = @metroid
	And			(LEN(@newflgv) = 0 OR CHARINDEX(',' + CAST(NewFlag AS nvarchar(1)) + ',',',' + @newflgv + ',') > 0)
	And			(LEN(@RestID) = 0 OR CHARINDEX(',' + CAST(r.RID AS nvarchar(5)) + ',',',' + @RestID + ',') > 0 And Allotment = 0)
	Order By r.RName Asc
END

ELSE 

BEGIN
	Select top 10 
				r.RID as Restaurant_ID
				,r.RName as restname
				,r.NewFlag
				,ma.MetroAreaName As metroname
				,coalesce(ERBBuild,'0') As ERBBuild
				,allotment
				,RestaurantTopList.Rank
				,n.NbhoodName as NeighborhoodName
				,FoodType.FoodType as food
				,PriceQuartileID
	From		RestaurantVW r
	Inner Join	NeighborhoodAVW n 
	On			n.NeighborhoodID = r.NeighborhoodID
	and			n.LanguageID = r.LanguageID
	Inner Join	MetroAreaAVW ma
	On			ma.MetroAreaID = n.MetroAreaID
	and			ma.LanguageID = r.LanguageID
	Inner Join	ERBRestaurant 
	ON			r.RID = ERBRestaurant.RID
	inner join	RestaurantTopList 
	on			r.RID = RestaurantTopList.RID
	INNER JOIN	FoodTypes 
	ON			r.RID = FoodTypes.RID 
	and			FoodTypes.IsPrimary = 1
	INNER JOIN	FoodType 
	ON			FoodTypes.FoodTypeID = FoodType.FoodTypeID
	where		ma.MetroAreaID = @metroid
	order by	Rank
END
GO

GRANT EXECUTE ON [Restaurant_GetNewByMetroAreaID] TO ExecuteOnlyRole

GO
