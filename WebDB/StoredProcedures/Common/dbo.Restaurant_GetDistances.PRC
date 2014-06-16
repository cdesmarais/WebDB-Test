if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetDistances]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetDistances]
GO


CREATE Procedure dbo.Restaurant_GetDistances
 (
 @rid_source int,		/* Restraunt ID */
 @lon float,	/* Restraunt Longitude */
 @lat float,	/* Restraunt Latitude */
 @MetroAreaID int,	/* Restraunt MetroArea ID - used to optimize query*/
 @distance float,	/* maximum distance in miles to accept nearby */
 @distList nvarchar(1000) output
 )
As
/******************************************************************************
	Compute the nearest restaurants within @distance miles of specified location
	Procedure will only process active restaurants (RestStateID = 1)
	Procedure will only process Restaurants in the same MetroArea
	
	Takes approx: 0.022 seconds per restaurant (per call)
	30 seconds to process 1347 restaurants
	
	Prodedure is intended to be called from a cursor that looks something like:
		declare rest_cur CURSOR FOR
		select rid, longitude, latitude, MetroAreaID
		from restaurant
		inner join neighborhood on restaurant.neighborhoodID = neighborhood.neighborhoodID
******************************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Declare @lat_min float, @lat_max float, @lon_min float, @lon_max float
	set @distList = ''

	set @lat_min = @lat - dbo.Simple_Dist_Lat_Offset(@distance)
	set @lat_max = @lat + dbo.Simple_Dist_Lat_Offset(@distance)

	set @lon_min = @lon - dbo.Simple_Dist_Lon_Offset(@distance) 
	set @lon_max = @lon + dbo.Simple_Dist_Lon_Offset(@distance) 

	
	declare dist_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select top 10 * 
	from
	(
	select r1.rid rid, 
		(dbo.Haversine_Distance(@lat, @lon, r1.latitude, r1.longitude)) dist
		from restaurant as r1 with (NOLOCK)
		where r1.rid != @rid_source
		and r1.latitude between @lat_min and @lat_max
		and r1.longitude between @lon_min and @lon_max
		and RestStateID = 1 /* Only include active restaurants */
		and NeighborhoodID in (select NeighborhoodID from neighborhood where MetroAreaID = @MetroAreaID) 
		/* optimization use index on Neighboorhod id */	
	) as tempdb1
	where dist <= @distance
	order by dist
	


	Declare @dist float
	Declare @rid int
	Declare @count int

	--** Iterate through results and construct a return string
	--** In the following format: RID/Distance, RID/Distance, ...
	--** NOTE: Distance is converted from miles to feet
	OPEN dist_cur
	FETCH NEXT FROM dist_cur 
	INTO @rid, @dist

	set @count = 0
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if (@count > 0)
			set @distList = @distList +  ','
			
		set @distList = @distList +  cast(@rid as nvarchar) + '/' + cast(round(@dist*5280,0) as nvarchar)

		set @count = @count + 1
		FETCH NEXT FROM dist_cur 
		INTO @rid, @dist
	END
	CLOSE dist_cur

	if (@distList = '')
		set @distList = null
		
go
		
		

GRANT EXECUTE ON [Restaurant_GetDistances] TO ExecuteOnlyRole

GO
