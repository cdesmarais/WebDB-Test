if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ListByNeighborhoodID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ListByNeighborhoodID]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_ListByNeighborhoodID
 (
  @HoodID int
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		r.RID AS RestaurantID,
			r.RName AS RestaurantName
FROM		RestaurantVW r
WHERE		(r.neighborhoodid = @HoodID)
ORDER BY	r.RName

GO

GRANT EXECUTE ON [Admin_Restaurant_ListByNeighborhoodID] TO ExecuteOnlyRole

GO
