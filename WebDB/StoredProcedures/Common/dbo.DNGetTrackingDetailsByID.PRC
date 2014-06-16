if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetTrackingDetailsByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetTrackingDetailsByID]
GO



CREATE PROCEDURE dbo.DNGetTrackingDetailsByID
 (
  @RID int
 )
As
SET NOCOUNT ON

Select 
	r.RName as RestName
	,ERBVersion
	, ListenerVersion
	, restaurantState.RState as StateName
	, Ping
	, isreachable as is_reachable
	, ServerIP as Server_IP
	, ProductDesc as Product_Description
	, StaticIPAddress
	, LTC as Last_time_Contacted
	, getdate() as FirstLog
	, ErbBuild as ERB_Build
	, Version
	, Track
	, getdate() as CurrentTime
from restaurantVW r

inner join erbrestaurant e	on r.RID = e.RID
inner join RestaurantState on r.RestStateID = RestaurantState.RestStateID
inner join lasttimeContacted on r.RID = lasttimeContacted.RID
inner join RestaurantProduct on e.ProductID = RestaurantProduct.ProductID

where r.RID = @RID
GO


GRANT EXECUTE ON [DNGetTrackingDetailsByID] TO ExecuteOnlyRole

GO
