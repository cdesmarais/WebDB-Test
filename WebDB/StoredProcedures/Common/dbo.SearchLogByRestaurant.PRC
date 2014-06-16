if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SearchLogByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SearchLogByRestaurant]
GO

CREATE PROCEDURE dbo.SearchLogByRestaurant
(
	@RID int,
	@BeginDateTime datetime,
	@EndDateTime datetime
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Declare @MacroNeighborhood int
, @Neighborhood int
Select @MacroNeighborhood = MacroID
, @Neighborhood = Restaurant.NeighborhoodID 
from Restaurant
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID
where RID = @RID

Declare @Todays_Search int
, @MacroSearch int
, @NeighborhoodSearch int
, @RestaurantSearch int

--Get Today's searches if desired

if (@EndDateTime > getdate() -1)
BEGIN
	Select @Todays_Search = coalesce(count(Search_ID),0) from search_log
	where 
	(CHARINDEX(',' + CAST(@RID AS nvarchar(16)) + ',', ',' + RID + ',') > 0)
	or 
	(CHARINDEX(',' + CAST(@RID AS nvarchar(16)) + ',', ',' + NeighborhoodID + ',') > 0)
	or 
	(CHARINDEX(',' + CAST(@RID AS nvarchar(16)) + ',', ',' + MacroID + ',') > 0)
END
else
BEGIN
	Set @Todays_Search = 0
END

--Get Restaurant searches
Select @RestaurantSearch = coalesce(count(*),0)
from Search_ByRestaurant
where search_log_Date > @BeginDateTime and search_log_Date < @EndDateTime
and 
(CHARINDEX(',' + CAST(@RID AS nvarchar(16)) + ',', ',' + RID + ',') > 0)


--Get Neighborhood Searches for this restaurant
Select @NeighborhoodSearch = coalesce(count(*),0)
from Search_ByNeighborhood
where search_log_Date > @BeginDateTime and search_log_Date < @EndDateTime
and
(CHARINDEX(',' + CAST(@Neighborhood AS nvarchar(16)) + ',', ',' + NeighborhoodID + ',') > 0)


--Get MacroSearches for this restaurant
Select @RestaurantSearch = coalesce(count(*),0)
from Search_ByMacroNeighborhood
where search_log_Date > @BeginDateTime and search_log_Date < @EndDateTime
and 
(CHARINDEX(',' + CAST(@MacroNeighborhood AS nvarchar(16)) + ',', ',' + MacroID + ',') > 0)



Select (@Todays_Search + @RestaurantSearch + @NeighborhoodSearch + @RestaurantSearch)
GO

GRANT EXECUTE ON [SearchLogByRestaurant] TO ExecuteOnlyRole

GO
