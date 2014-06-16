if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantRooms]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantRooms]
GO


/*
This proc is used by OT_MgrCache/StoredProcTab.cs in ConsumerSite to fetch data for WebCache
*/
CREATE Procedure dbo.DNCacheRestaurantRooms

As

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	RoomID
		,RID
   		,RoomName
		,RoomDescription
		,SeatedSize
		,StandingSize
		,ImageName
		,ListingOrder
FROM	restaurantrooms 
where 	active = 1

GO





GRANT EXECUTE ON [dbo].[DNCacheRestaurantRooms] TO ExecuteOnlyRole

GO
