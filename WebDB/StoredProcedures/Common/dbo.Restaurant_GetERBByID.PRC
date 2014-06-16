if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetERBByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetERBByID]
GO

CREATE Procedure dbo.Restaurant_GetERBByID
 (
  @RestaurantID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT er.ServerIP AS NetAddress,
    er.serverPwd AS Password,
    tz._offsetHR AS TimeZoneOffset,
    er.ERBVersion as ERBVersion,
    er.ListenerVersion as ListenerVersion
FROM ERBRestaurant er
INNER JOIN Restaurant r  
ON er.RID = r.RID 
INNER JOIN TimeZone tz 
ON r.TZID = tz.TZID 
WHERE (er.RID = @RestaurantID)

GO

GRANT EXECUTE ON [Restaurant_GetERBByID] TO ExecuteOnlyRole

GO
