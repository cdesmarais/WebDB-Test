if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_Restaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_Restaurant]
GO


CREATE PROCEDURE dbo.Delete_Restaurant
(
    @RID int
)

AS

Delete from SetValQueue where rid = @RID
Delete from ValueLookupIDList where LookupID in (3,51) and ValueID = @RID
Delete from RestaurantCustomMessage where rid = @RID
Delete from ERBRestaurant where rid = @RID
Delete from RestNameChange where rid = @RID
Delete from RestaurantJustAdded where rid = @RID
Delete from RestaurantLocal where rid = @RID
Delete from FoodTypes where rid = @RID
Delete from RestaurantBrandLog where rid = @RID
Delete from RestaurantTypeLog where rid = @RID
Delete from ERBVersionHistory where rid = @RID
Delete from restaurant where rid = @RID


GO

GRANT EXECUTE ON [Delete_Restaurant] TO ExecuteOnlyRole

GO
