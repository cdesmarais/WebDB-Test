if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserListFavoritesByMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserListFavoritesByMetro]
GO

CREATE Procedure dbo.UserListFavoritesByMetro
 (
  @UserID int,
  @MetroAreaID int,
  @IsCaller int = 0  --this param really just indicates if @UserID is a userid or a CallerID
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
if @IsCaller = 0
BEGIN
SELECT r.RName AS RestaurantName
,r.RID as RestaurantID
,UpdatedFavorites
from RestaurantVW r
INNER JOIN Neighborhood n 
On r.neighborhoodid = n.neighborhoodid
INNER JOIN Favorites f
ON r.RID = f.RID
INNER JOIN  Customer c
ON f.CustID = c.CustID
Where f.CustID = @UserID 
and n.metroareaid = @MetroAreaID

ORDER BY r.RName

END

if @IsCaller > 0
BEGIN
SELECT r.RName AS RestaurantName
,r.RID as RestaurantID
,UpdatedFavorites
from RestaurantVW r
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
INNER JOIN CallerRestaurants cr
ON r.RID = cr.RID
INNER JOIN  Caller c
ON cr.CallerID = c.CallerID
Where cr.CallerID = @UserID 
and n.metroareaid = @MetroAreaID
ORDER BY r.RName

END
GO

GRANT EXECUTE ON [UserListFavoritesByMetro] TO ExecuteOnlyRole

GO
