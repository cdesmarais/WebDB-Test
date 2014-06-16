if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_ListByGeoID]
GO

CREATE Procedure dbo.Concierge_Restaurant_ListByGeoID
 (
  @GeoID int
 )
As
--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @time_offset real

SELECT r.RID AS RestaurantID,
    r.RName AS RestaurantName
FROM RestaurantVW r
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid 
INNER JOIN    ERBRestaurant 
ON    r.RID = ERBRestaurant.RID
WHERE (n.metroareaid = @GeoID) 
AND (r.RestStateID = 1) 
AND ((r.IsReachable = 1) or ( r.Allotment = 1 and r.RestStateID = 1))
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
ORDER BY r.RName

GO

GRANT EXECUTE ON [Concierge_Restaurant_ListByGeoID] TO ExecuteOnlyRole

GO
