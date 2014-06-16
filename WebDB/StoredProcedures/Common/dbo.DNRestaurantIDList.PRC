if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantIDList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantIDList]
GO


CREATE Procedure dbo.DNRestaurantIDList
As

set transaction isolation level read uncommitted
SET NOCOUNT ON

SELECT DISTINCT
			  er.RID AS [RID]
			, er.ServerIP AS ERBIPAddr
			, er.serverPwd AS AccessPass
			, er.ERBVersion AS ERBVersion
			, er.ListenerVersion AS ListenerVersion

FROM		Restaurant r
INNER JOIN	ERBRestaurant er
ON			r.RID = er.RID
INNER JOIN	RestaurantState rs
ON			r.RestStateID = rs.RestStateID
WHERE		er.ListenerVersion is not null
AND			er.ListenerVersion <> ''
AND			r.RestStateID != 4 --inactive
ORDER BY	[RID]


GO


GRANT EXECUTE ON [DNRestaurantIDList] TO ExecuteOnlyRole

GO
