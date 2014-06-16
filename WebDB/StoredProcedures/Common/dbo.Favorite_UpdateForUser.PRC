if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Favorite_UpdateForUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Favorite_UpdateForUser]
GO

CREATE Procedure dbo.Favorite_UpdateForUser
 (
  @UserID int,
  @GeoID int,
  @Restaurants nvarchar(1999) =  '',
  @IsCaller int = 0  --this param indicates if @UserID is a user_id or a caller_id
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION

declare @i int

if (@Restaurants is not null) /*very important! This avoids endless looping when null is entered!*/
BEGIN
	--if ((@Restaurants <> '') AND (right(@Restaurants,1) <> ',')) select @Restaurants= @Restaurants + ','
	if @IsCaller = 0
	BEGIN
		Update Customer set UpdatedFavorites = 1 where CustID = @UserID

		DELETE  FROM Favorites WHERE
   		CustID = @UserID
		and
		RID in (select RID from Restaurant r
		inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid
		--inner join MetroArea on MetroArea.metroareaid = n.metroareaid
		where n.metroareaid = @GeoID)
  		if ((@Restaurants <> '') AND (right(@Restaurants,1) <> ',')) select @Restaurants= @Restaurants + ','
		while 1=1
 			begin
  			select @i= charindex(',',@Restaurants)
  			if @i = 0 break
  			insert into Favorites(CustID,RID)
   			select @UserID,convert(int,substring(@Restaurants,1,@i - 1))
  			select @Restaurants= substring(@Restaurants,@i + 1,999)
  			end
	END
	if @IsCaller > 0
	BEGIN
		Update Caller set UpdatedFavorites = 1 where CallerID = @UserID
		
  		DELETE  FROM CallerRestaurants WHERE
    		CallerID =  @UserID
  		and
		RID in (select RID from Restaurant r
		inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid
		--inner join MetroArea on MetroArea.metroareaid = n.metroareaid
		where n.metroareaid = @GeoID)
  		if ((@Restaurants <> '') AND (right(@Restaurants,1) <> ',')) select @Restaurants= @Restaurants + ','
  		while 1=1
  			begin
  			select @i= charindex(',',@Restaurants)
  			if @i = 0 break
  			insert into CallerRestaurants(CallerID,RID)
   			select @UserID,convert(int,substring(@Restaurants,1,@i - 1))
  			select @Restaurants= substring(@Restaurants,@i + 1,999)
  			end
	END
END

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Favorite_UpdateForUser] TO ExecuteOnlyRole

GO
