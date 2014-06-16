if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ListAllByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ListAllByGeoID]
GO

CREATE Procedure dbo.Admin_ListAllByGeoID
 (
  @GeoID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
			r.RID AS RestaurantID,
			r.RName AS RestaurantName
FROM		RestaurantVW r 
INNER JOIN	Neighborhood n 
ON			r.neighborhoodid = n.neighborhoodid
WHERE		n.metroareaid = @GeoID
ORDER BY	r.RName

GO

GRANT EXECUTE ON [Admin_ListAllByGeoID] TO ExecuteOnlyRole

GO
