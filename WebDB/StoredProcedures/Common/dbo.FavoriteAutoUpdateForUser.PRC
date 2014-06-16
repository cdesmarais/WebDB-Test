if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FavoriteAutoUpdateForUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FavoriteAutoUpdateForUser]
GO

CREATE Procedure dbo.FavoriteAutoUpdateForUser
 (
  @UserID int,
  @RestaurantID int,
  @CallerID int = 0  --this param indicates if @UserID is a user_id or a caller_id
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION
if (@CallerID = 0)
BEGIN
	if exists(Select CustID from Customer where UpdatedFavorites = 0 and @UserID = CustID and ConsumerType <> 8)
	BEGIN
		/*add to favorites only if it's not there*/
		insert into Favorites (RID,CUSTID) VALUES (@RestaurantID,@UserID)
	END
END
else
BEGIN
	if exists(Select CallerID from Caller where UpdatedFavorites = 0 and @CallerID = CallerID and ConsumerType <> 8)
	BEGIN
		if not exists(Select RID from CallerRestaurants where CallerID = @CallerID and RID = @RestaurantID and FolderID = 0)
		BEGIN		
			insert into CallerRestaurants (CallerID,RID,FolderID) VALUES (@CallerID,@RestaurantID,0)
		END
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

GRANT EXECUTE ON [FavoriteAutoUpdateForUser] TO ExecuteOnlyRole

GO
