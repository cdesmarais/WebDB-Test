if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodTypes_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodTypes_Update]
GO

CREATE PROCEDURE dbo.Admin_FoodTypes_Update
 (
  @RestaurantID int,
  @FoodTypeID int,
  @IsPrimary bit
 )
As
SET NOCOUNT ON
EXECUTE Admin_FoodTypes_Delete @RestaurantID
EXECUTE Admin_FoodTypes_Add @RestaurantID,@FoodTypeID,@IsPrimary

GO

GRANT EXECUTE ON [Admin_FoodTypes_Update] TO ExecuteOnlyRole

GO
