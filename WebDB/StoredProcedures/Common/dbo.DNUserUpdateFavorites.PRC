if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserUpdateFavorites]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserUpdateFavorites]
GO

CREATE Procedure dbo.DNUserUpdateFavorites
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
if (@Restaurants is not null) 
BEGIN
	if @IsCaller = 0
	BEGIN
		Update Customer set UpdatedFavorites = 1 where CustID = @UserID

		--*******************
		--Remove the RIDs that are no longer in the rid set
		--*******************
  		DELETE  Favorites 
		FROM Favorites c
  		left outer join dbo.fIDStrToTab(@Restaurants, ',') rTab on c.rid = rTab.id
  		WHERE CustID =  @UserID
  			--RID is in the metro
  		and RID in (select RID from Restaurant r
					inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid
					where n.metroareaid = @GeoID)
			--RID is not in Restaurant Set
		and rTab.id is null

		--*******************
		-- Insert only the RIDs that are not already in the Favorites table
		--*******************
		INSERT INTO Favorites(CustID,RID)
			SELECT @UserID, id
			from dbo.fIDStrToTab(@Restaurants, ',') rTab
			left outer join Favorites c on rTab.id = c.rid 
												and c.CustID = @UserID
			where c.rid is null
			  			
	END
	if @IsCaller > 0
	BEGIN
		Update Caller set UpdatedFavorites = 1 where CallerID = @UserID
		
		--*******************
		--Remove the RIDs that are no longer in the rid set
		--*******************
  		DELETE  CallerRestaurants 
		FROM CallerRestaurants c
  		left outer join dbo.fIDStrToTab(@Restaurants, ',') rTab on c.rid = rTab.id
  		WHERE CallerID =  @UserID
  			--RID is in the metro
  		and RID in (select RID from Restaurant r
					inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid
					where n.metroareaid = @GeoID)
			--RID is not in Restaurant Set
		and rTab.id is null

		--*******************
		-- Insert only the RIDs that are not already in the CallerRestaurant table
		--*******************
		INSERT INTO CallerRestaurants(CallerID,RID)
			SELECT @UserID, id
			from dbo.fIDStrToTab(@Restaurants, ',') rTab
			left outer join CallerRestaurants c on rTab.id = c.rid 
												and c.CallerID = @UserID
			where c.rid is null
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

GRANT EXECUTE ON [DNUserUpdateFavorites] TO ExecuteOnlyRole

GO
