if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_CallerList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_CallerList]
GO

CREATE Procedure dbo.Concierge_Restaurant_CallerList
 (
  @CallerID int,
  @CompanyID int
 )
As

set transaction isolation level read uncommitted

if @CallerID > 0
SELECT distinct r.RID AS RestaurantID,
r.RName AS RestaurantName
FROM RestaurantVW r
INNER JOIN Reservation 
ON r.RID=Reservation.RID
WHERE CallerID=@CallerID
ORDER BY r.RName

if @CallerID = 0
SELECT distinct r.RID AS RestaurantID
,r.RName AS RestaurantName
FROM RestaurantVW r
INNER JOIN Reservation 
ON r.RID=Reservation.RID
WHERE CompanyID=@CompanyID
ORDER BY r.RName

GO

GRANT EXECUTE ON [Concierge_Restaurant_CallerList] TO ExecuteOnlyRole

GO
