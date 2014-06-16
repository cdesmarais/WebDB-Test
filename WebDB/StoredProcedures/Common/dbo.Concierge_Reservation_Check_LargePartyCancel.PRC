if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Check_LargePartyCancel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Check_LargePartyCancel]
GO

CREATE PROCEDURE dbo.Concierge_Reservation_Check_LargePartyCancel

@ReservationID int,
@retval bit OUTPUT

AS

set transaction isolation level read uncommitted

if (Select LargeParty from Reservation where ResID = @ReservationID) = 1
BEGIN
   declare @ResDateTime datetime,
   @RestaurantID int,
   @ServerTZID int,
   @Restaurantoffset int,
   @ServerOffset int,
   @RestDate datetime

   exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

   --get the ResDateTime and RestaurantID
   Select @ResDateTime = cast((Select ShiftDate from Reservation where ResID = @ReservationID) as datetime)
   Select @RestaurantID = (Select RID from Reservation where ResID = @ReservationID)

   --get time related variables for final calculation
   --Select @ServerTZID = 7
   Select @RestaurantOffset = (select _offsetHR from TimeZone tz inner join Restaurant r on tz.TZID = r.TZID where RID = @RestaurantID)
   Select @ServerOffset = (select _offsetHR from TimeZone where TZID = @ServerTZID)
   Select @RestDate = (dateadd(Hour,(@RestaurantOffset - @ServerOffset),getDate()))

   --final calculation
   if   (datepart(day,@ResDateTime) - datepart(day,@RestDate) <=  0) or (  (datepart(day,@ResDateTime) - datepart(day,@RestDate)  = 1) and (datepart(hour,@RestDate) > 12)   )
	BEGIN
	   Select @retval = 0
	   Return(0)
	END
   else
	BEGIN
	   Select @retval = 1
	   Return(0)
	END
END

/*if it is not a large party return true*/
Select @retval = 1
Return(0)

GO

GRANT EXECUTE ON [Concierge_Reservation_Check_LargePartyCancel] TO ExecuteOnlyRole

GO
