if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ConciergeHotelBlockedRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ConciergeHotelBlockedRestaurant]
GO


/*revised for new schema 8/1/2003 */


CREATE PROCEDURE dbo.ConciergeHotelBlockedRestaurant
(
    @HotelID int,
    @RestaurantID int,
    @retval bit output
)
AS
if exists(Select HotelID from CompanyNonRestaurants where HotelID = @HotelID and RID = @RestaurantID)
BEGIN
	Set @retval = 1
END
else
BEGIN
	Set @retval = 0
END
GO

GRANT EXECUTE ON [ConciergeHotelBlockedRestaurant] TO ExecuteOnlyRole

GO
