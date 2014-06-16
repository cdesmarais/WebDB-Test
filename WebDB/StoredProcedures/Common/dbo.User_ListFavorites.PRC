if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_ListFavorites]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_ListFavorites]
GO

CREATE Procedure dbo.User_ListFavorites
 (
  @UserID int,
  @IsCaller int = 0
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @IsCaller = 0
BEGIN
SELECT r.RName AS RestaurantName
,m.metroareaid as Metro_Area_ID
,m.MetroAreaName as Metroname
,r.RID as Restaurant_ID
from RestaurantVW r
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
INNER JOIN MetroAreaAVW m
ON n.metroareaid = m.metroareaid
and r.LanguageID = m.LanguageID
INNER JOIN Favorites 
ON r.RID = Favorites.RID
Where Favorites.CustID = @UserID

ORDER BY m.metroareaid
,r.RName

END

if @IsCaller > 0
BEGIN
SELECT r.RName AS RestaurantName
,m.metroareaid as Metro_Area_ID
,m.MetroAreaName as Metroname
,r.RID as Restaurant_ID
from RestaurantVW r
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
INNER JOIN MetroAreaAVW m 
ON n.metroareaid = m.metroareaid
and r.LanguageID = m.LanguageID
INNER JOIN     CallerRestaurants cr
ON   r.RID = cr.RID
Where cr.CallerID = @UserID

ORDER BY m.metroareaid
,r.RName

END
GO

GRANT EXECUTE ON [User_ListFavorites] TO ExecuteOnlyRole

GO
