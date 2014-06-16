if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUserSimilar_PopulateTab]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUserSimilar_PopulateTab]
GO

CREATE Procedure dbo.RestaurantUserSimilar_PopulateTab
as

--PROCEDURE IS NOW MOVED TO OTREPORTS
--REPLACED BY WEBAGG_RestaurantUserSimilar_PopulateTab
--
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

	declare @rid int, @MacroID int
	declare @userList nvarchar(1000)

	declare rest_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select rid, MacroID
	from restaurant with (NOLOCK)
	inner join neighborhood on restaurant.neighborhoodID = neighborhood.neighborhoodID
	where RestStateID in (1,7,13,16)
	order by rid

	--** Remove all existing entries in the nearby table
	delete RestaurantUserSimilar
	
	--** Process all Nearby Restaurants
	OPEN rest_cur

	FETCH NEXT FROM rest_cur 
	INTO @rid, @MacroID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC [User_Get_Similar_Rests] @rid,  @MacroID, @userList output
			
		insert into RestaurantUserSimilar (rid, SimilarList) values (@rid, @userList);

		FETCH NEXT FROM rest_cur 
		INTO @rid, @MacroID	
	END
	
	CLOSE rest_cur

	if @@ERROR <> 0
		goto error

	COMMIT TRANSACTION

	Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN('RestaurantUserSimilar_PopulateTab FAIL: ' + cast(@@ERROR as nvarchar))

end

go



GRANT EXECUTE ON [RestaurantUserSimilar_PopulateTab] TO ExecuteOnlyRole

GO
