if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_Check_LargePartyCancel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_Check_LargePartyCancel]
GO

CREATE PROCEDURE dbo.Reservation_Check_LargePartyCancel

@ReservationID int,
@retval int OUTPUT

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

Select @ResDateTime = cast((Select ShiftDate from Reservation where ResID = @ReservationID) as datetime)
Select @RestaurantID = (Select RID from Reservation where ResID = @ReservationID)

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

Select @RestaurantOffset = (select _offsetHR from TimeZone tz inner join Restaurant r on tz.TZID = r.TZID where RID = @RestaurantID)
Select @ServerOffset = (select _offsetHR from TimeZone where TZID = @ServerTZID)
Select @RestDate = (dateadd(Hour,(@RestaurantOffset - @ServerOffset),getDate()))

   --final calculation
   if   (   (datepart(month,@ResDateTime) = datepart(month,@RestDate))   /* it is the same year */  
            and  (datepart(year,@ResDateTime) = datepart(year,@RestDate))  /* it is the same month */

            and  (  
                     (datepart(day,@ResDateTime) - datepart(day,@RestDate) <=  1) /* it is the same day */
	        or (   (datepart(day,@ResDateTime) - datepart(day,@RestDate)  = 2) and (datepart(hour,@RestDate) >= 17)   )  /* it is the day before the reso and after fivepm */
	       )
        ) 
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

Select @retval = 1
Return(0)
GO

GRANT EXECUTE ON [Reservation_Check_LargePartyCancel] TO ExecuteOnlyRole

GO
