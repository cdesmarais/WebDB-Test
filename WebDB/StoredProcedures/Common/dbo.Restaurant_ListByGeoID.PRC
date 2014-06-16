if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListByGeoID]
GO

CREATE Procedure dbo.Restaurant_ListByGeoID
 (
  @GeoID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT     r.RID			AS RestaurantID
          ,r.RName          AS RestaurantName
FROM       RestaurantVW r
INNER JOIN NeighborhoodAVW n 
ON         r.NeighborhoodID     = n.NeighborhoodID 
and			r.LanguageID = n.LanguageID
and        n.MetroAreaID     = @GeoID
WHERE      r.RestStateID in (1,5,6,13)
AND      ((r.IsReachable = 1)   or (r.Allotment           = 1 and r.RestStateID = 1))
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
ORDER BY   r.RName

GO

GRANT EXECUTE ON [Restaurant_ListByGeoID] TO ExecuteOnlyRole

GO
