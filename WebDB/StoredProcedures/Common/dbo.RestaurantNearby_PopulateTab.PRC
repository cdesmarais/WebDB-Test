if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantNearby_PopulateTab]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantNearby_PopulateTab]
GO

CREATE Procedure dbo.RestaurantNearby_PopulateTab
(
@distance int  -- maximum distance to accept nearby retaurant
)

as
/******************************************************************************
Procedure iterates through all Restaurants in Restaurant table
and populates a table RestaurantNearby
a list of the top 10 nearest restaurants for each restaurant

Format of results is:
<RID_Source> <RID/Distance,RID/Distance,RID/Distance,RID/Distance>

Where <RID_Source> is the RID of the restuarant tht the distance list is relative too

<RID/Distance, ...> Is a comma deliited list in order of nearest restaurants
					RID is the nearby restaurant
					Distance is the distance in miles to 3 decimel places
******************************************************************************/
begin
SET NOCOUNT ON

SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION

	declare @rid int, @MetroAreaID int
	declare @lon float, @lat float
	declare @distList nvarchar(1000)

	declare rest_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select rid, longitude, latitude, MetroAreaID
	from restaurant with (NOLOCK)
	inner join neighborhood on restaurant.neighborhoodID = neighborhood.neighborhoodID
	where RestStateID in (1,7,13,16)
	order by rid

	--** Remove all existing entries in the nearby table
	delete RestaurantNearby;
	
	--** Process all Nearby Restaurants
	OPEN rest_cur

	FETCH NEXT FROM rest_cur 
	INTO @rid, @lon, @lat, @MetroAreaID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC [Restaurant_GetDistances] @rid, @lon, @lat, 
			@MetroAreaID, @distance, @distList output

		insert into RestaurantNearby (rid, NearbyList) values (@rid, @distList);
		

		FETCH NEXT FROM rest_cur 
		INTO @rid, @lon, @lat, @MetroAreaID		
	END
	
	CLOSE rest_cur

	if @@ERROR <> 0
		goto error

	COMMIT TRANSACTION

	Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN('RestaurantNearby_PopulateTab FAILED: ' + cast(@@ERROR as nvarchar))

end

go


GRANT EXECUTE ON [RestaurantNearby_PopulateTab] TO ExecuteOnlyRole

GO
