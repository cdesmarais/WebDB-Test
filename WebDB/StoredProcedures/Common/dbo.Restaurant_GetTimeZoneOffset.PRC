if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetTimeZoneOffset]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetTimeZoneOffset]
GO

CREATE PROCEDURE dbo.Restaurant_GetTimeZoneOffset 
(
@RestaurantID int,
@ReservationID int,
@retval int OUTPUT
)

AS
SET NOCOUNT ON
if @RestaurantID <> 0
BEGIN
	Select @retval = (Case when ERBRestaurant.FixedTimeOffset = 1 then -8 else tz._offsetHR END)
	from ERBRestaurant
	inner join Restaurant r on ERBRestaurant.RID = r.RID
	inner join TimeZone tz on r.TZID = tz.TZID
	where ERBRestaurant.RID = @RestaurantID
END
else
BEGIN
	Select @retval = (Case when ERBRestaurant.FixedTimeOffset = 1 then -8 else tz._offsetHR END)
	from ERBRestaurant
	inner join Reservation on ERBRestaurant.RID = Reservation.RID
	inner join Restaurant r on ERBRestaurant.RID = r.RID
	inner join TimeZone tz on r.TZID = tz.TZID
	where Reservation.ResID = @ReservationID
END
GO

GRANT EXECUTE ON [Restaurant_GetTimeZoneOffset] TO ExecuteOnlyRole

GO
