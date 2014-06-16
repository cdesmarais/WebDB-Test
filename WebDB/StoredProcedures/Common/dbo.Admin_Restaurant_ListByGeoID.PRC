if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ListByGeoID]
GO

CREATE Procedure dbo.Admin_Restaurant_ListByGeoID
 (
  @GeoID int,
  @RestaurantID int=0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @newflgv nvarchar(1),@RestID nvarchar(5)
if @RestaurantID = 0 SELECT @RestID = ''
if @RestaurantID > 0 SELECT @RestID = @RestaurantID

SELECT		r.RID AS RestaurantID,
			r.RName AS RestaurantName,
			r.NewFlag,
			ma.MetroAreaName As metroname,
			IsNull(ERBBuild,'0') As ERBBuild,
			allotment
From		RestaurantVW r
Inner Join	Neighborhood n 
On			r.neighborhoodid = n.neighborhoodid
Inner Join	MetroAreaAVW ma
On			ma.metroareaid = n.metroareaid
and			ma.LanguageID = r.LanguageID
Inner Join	ERBRestaurant 
ON			r.RID = ERBRestaurant.RID
WHERE		(ma.MetroAreaID = @GeoID)
And			(LEN(@RestID) = 0 OR
			CHARINDEX(',' + CAST(r.RID AS nvarchar(5))
				+ ',',',' + @RestID + ',') > 0 
			)
ORDER BY	r.RName Asc

GO

GRANT EXECUTE ON [Admin_Restaurant_ListByGeoID] TO ExecuteOnlyRole

GO
