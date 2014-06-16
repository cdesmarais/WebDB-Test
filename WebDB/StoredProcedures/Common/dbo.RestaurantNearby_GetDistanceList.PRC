if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantNearby_GetDistanceList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantNearby_GetDistanceList]
GO

CREATE Procedure dbo.RestaurantNearby_GetDistanceList
as
/******************************************************************************
Procedure iterates through all Restaurants in Restaurant table
and produces a list of the top 10 nearest restaurants for each restaurant

Format of results is:
<RID_Source> <RID/Distance,RID/Distance,RID/Distance,RID/Distance>

Where <RID_Source> is the RID of the restuarant tht the distance list is relative too

<RID/Distance, ...> Is a comma deliited list in order of nearest restaurants
					RID is the nearby restaurant
					Distance is the distance in feet
******************************************************************************/
Set nocount on
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	select rid as rid
	, NearbyList as nearby
	from RestaurantNearby
	order by rid

GO


GRANT EXECUTE ON [RestaurantNearby_GetDistanceList] TO ExecuteOnlyRole

GO
