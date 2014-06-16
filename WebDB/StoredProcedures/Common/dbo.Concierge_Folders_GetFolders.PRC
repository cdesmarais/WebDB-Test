if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Folders_GetFolders]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Folders_GetFolders]
GO


CREATE Procedure dbo.Concierge_Folders_GetFolders
 (
  @User_ID int,
  @GeoID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION
if @GeoID <> 0 
BEGIN

(Select 'Past Reservations' as FName,'0' as FID
,(select count(cr.FolderID)
from CallerRestaurants cr
INNER JOIN Restaurant r
ON cr.RID = r.RID
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
where cr.FolderID = 0 
and CallerID = @User_ID 
and n.metroareaid = @GeoID) as fav_total
from CallerRestaurants cr 
where cr.CallerID = @User_ID) 
union
(Select FavoritesFolder.FolderName as FName,FavoritesFolder.FFolderID as FID,
(select count(cr.FolderID)
from CallerRestaurants cr
INNER JOIN Restaurant r 
ON cr.RID = r.RID
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
where cr.FolderID = FFolderID 
and CallerID = @User_ID 
and n.metroareaid = @GeoID and r.RestStateID in (1,5,6)) as fav_total
from FavoritesFolder 
where UserID = @User_ID 
and IsCaller = 1 
and FavoritesFolder.MetroID = @GeoID)
ORDER BY FID

END
else
BEGIN

(Select 'Past Reservations' as FName,'0' as FID,
(select count(cr.FolderID)
from CallerRestaurants cr
INNER JOIN Restaurant r
ON cr.RID = r.RID
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
where cr.FolderID = 0 
and CallerID = @User_ID) as fav_total,'0' as MetroID
from CallerRestaurants cr
where cr.CallerID = @User_ID) 
union
(Select FavoritesFolder.FolderName as FName,FavoritesFolder.FFolderID as FID,
(select count(cr.FolderID)
from CallerRestaurants cr
INNER JOIN Restaurant r
ON cr.RID = r.RID
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
where cr.FolderID = FFolderID 
and CallerID = @User_ID and r.RestStateID in (1,5,6)) as fav_total
,FavoritesFolder.MetroID
from FavoritesFolder 
where UserID = @User_ID 
and IsCaller = 1)

ORDER BY MetroID
,FID

END

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
	

GO

GRANT EXECUTE ON [Concierge_Folders_GetFolders] TO ExecuteOnlyRole

GO
