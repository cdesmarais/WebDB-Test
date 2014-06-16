if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheERBInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheERBInfo]
GO

CREATE   Procedure dbo.DNCacheERBInfo
AS

set transaction isolation level read uncommitted
SET NOCOUNT ON

-- TODO: Consider excluding inactive restaurants
-- It's considered better to cache everything since if an initially cached item is missing and an ERB comes online it will be hitting the
-- db too much.
-- At present this is used heavily by 
-- b.aspx.  If you change this you _must_ heavily regression test BRUP.
-- Currently only The ServerPassword is needed to be returned.  Consider removing the other three columns.

SELECT 
	ERBRestaurant.RID as RID
	, (case when (charindex(':',serverIP) > 0)
		then substring(serverIP, 1, charindex(':',ERBRestaurant.serverIP)-1) 
		else ''
		end) as ServerIP
	, (case when (charindex(':',serverIP) > 0)
		then cast(substring(serverIP, charindex(':',ERBRestaurant.serverIP)+1, 10) as int)
		else -1
		end) as ServerPort
	, ERBRestaurant.ERBVersion AS ERBVersion
	, ERBRestaurant.ServerPwd AS ServerPassword
	, Restaurant.RestaurantType   AS RestaurantType
FROM		ERBRestaurant 
INNER JOIN Restaurant 
ON ERBRestaurant.RID = Restaurant.RID
GO

GRANT EXECUTE ON [DNCacheERBInfo] TO ExecuteOnlyRole
GO
