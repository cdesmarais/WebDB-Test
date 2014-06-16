if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promo_Rest_NonOT_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promo_Rest_NonOT_Get]
GO


CREATE PROCEDURE dbo.Admin_Promo_Rest_NonOT_Get
(
  @metro_ID int,
  @promo_ID int
)
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE

Select RestaurantName as Restaurant_Name,Phone,Address,City from PromoNonOTRestaurants where MetroID = @metro_ID and PromoID = @promo_ID
GO

GRANT EXECUTE ON [Admin_Promo_Rest_NonOT_Get] TO ExecuteOnlyRole

GO
