if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheTopTenRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheTopTenRestaurants]
GO

--*********************************************************
--** Retrieves a list of top ten lists, used to populate the
--** top ten user control and the top ten landing page
--*********************************************************

create procedure dbo.DNCacheTopTenRestaurants
as
set transaction isolation level read uncommitted
set nocount on
	
	--Ratings data display
	declare @ReviewInceptionDays int
	declare @ReviewInceptionCutoffDate datetime

	--Ratings data display logic
	select	@ReviewInceptionDays = ValueInt 
	from	ValueLookup 
	where	LKey = 'RestReviewInceptionDays' 
	and		LType = 'WEBSERVER'

	set		@ReviewInceptionDays = ISNULL(@ReviewInceptionDays, 30)
	set		@ReviewInceptionCutoffDate = DATEADD(dd, @ReviewInceptionDays*-1, GETDATE())

	select		 MetroAreaID
				,CAST(ttr.TopTenListInstanceID as nvarchar(15)) + ':' + CAST(ttr.RID as nvarchar(15)) as UniqueID
				,TopTenListInstanceID
				,ttr.RID
				,RName
				,[Rank]
				,NbhoodName
				,NeighborhoodID
				,FoodType
				,Symbols
				,ri.ThumbnailName as RestaurantImageThumbnail 
				,(case when(coalesce(dffs.BlackListFlag, 0) = 1) then -1
					   when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0
					   else coalesce(dffs.totaldffs, 0) end) as totaldffs
				,(case when (coalesce(dffs.BlackListFlag, 0) = 1) then -1 
					   when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 0 
					   else coalesce(AverageOverallRating, 0) end) as AverageOverallRating
				,case when(rja.DateAdded is not null and rja.DateAdded > @ReviewInceptionCutoffDate) then 1
					  else 0 end as RestaurantComingSoon
	from toptenrestaurantvw ttr
	left join	DFFDailySummaryRIDStatsHolding dffs
	on			ttr.rid = dffs.webrid
	left join	RestaurantJustAdded rja
	on			ttr.rid = rja.rid
	left join	RestaurantImage ri
	on			ttr.rid = ri.RID
	where		[Rank] between 1 and 10
	and 		TopTenListInstanceIsActive=1
	order by TopTenListInstanceID, [Rank]

go

grant execute on [DNCacheTopTenRestaurants] TO ExecuteOnlyRole

go


