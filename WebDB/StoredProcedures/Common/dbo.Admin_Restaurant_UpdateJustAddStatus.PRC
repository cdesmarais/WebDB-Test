if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateJustAddStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateJustAddStatus]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_UpdateJustAddStatus
(
  @RestID nvarchar(255),
  @MetroID int
)
AS

Update RestaurantJustAdded
Set JustAdded = 0
Where RID IN(Select RestaurantJustAdded.RID From RestaurantJustAdded
Inner Join Restaurant r On RestaurantJustAdded.RID = r.RID
Inner Join Neighborhood n On r.neighborhoodid = n.neighborhoodid
Where n.metroareaid = @MetroID)


Update RestaurantJustAdded
Set JustAdded = 1
Where CHARINDEX(',' + CAST(RID AS nvarchar(500)) + ',',',' + @RestID + ',') > 0

GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateJustAddStatus] TO ExecuteOnlyRole

GO
