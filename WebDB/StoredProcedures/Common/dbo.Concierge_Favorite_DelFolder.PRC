if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Favorite_DelFolder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Favorite_DelFolder]
GO

CREATE Procedure dbo.Concierge_Favorite_DelFolder
 (
  @UserID int,
  @GeoID int,
  @FolderID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

DELETE CallerRestaurants
FROM CallerRestaurants cr
INNER JOIN Caller 
ON cr.CallerID = Caller.CallerID
INNER JOIN Restaurant r 
ON cr.RID = r.RID
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
WHERE (Caller.CallerID = @UserID) AND
    (n.metroareaid = @GeoID) AND (cr.FolderID = @FolderID)


DELETE FavoritesFolder
FROM FavoritesFolder
WHERE (UserID = @UserID) AND (FFolderID = @FolderID)

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
	
GO

GRANT EXECUTE ON [Concierge_Favorite_DelFolder] TO ExecuteOnlyRole

GO
