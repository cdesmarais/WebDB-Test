if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_CheckLargeParty_ResoTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_CheckLargeParty_ResoTime]
GO

CREATE PROCEDURE dbo.Reservation_CheckLargeParty_ResoTime

@RestaurantID int,
@ResDateTime datetime,
@retval int OUTPUT

AS

set transaction isolation level read uncommitted

declare @ServerTZID int,
@Restaurantoffset int,
@ServerOffset int,
@RestDate datetime


exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

Select @RestaurantOffset = (select _offsetHR from TimeZone tz inner join Restaurant r on tz.TZID = r.TZID where RID = @RestaurantID)
Select @ServerOffset = (select _offsetHR from TimeZone where TZID = @ServerTZID)
Select @RestDate = (dateadd(Hour,(@RestaurantOffset - @ServerOffset),getDate()))
   
   --final calculation
   if   (   (datepart(month,@ResDateTime) = datepart(month,@RestDate))   /* it is the same year */  
            and  (datepart(year,@ResDateTime) = datepart(year,@RestDate))  /* it is the same month */

            and  (  
                     (datepart(day,@ResDateTime) - datepart(day,@RestDate) <=  0) /* it is the same day */
	        or (   (datepart(day,@ResDateTime) - datepart(day,@RestDate)  = 1) and (datepart(hour,@RestDate) >= 17)   )  /* it is the day before the reso and after fivepm */
	       )
        ) 
	BEGIN
	   --Select retval = 0
	   Select @retval = 0
	   Return(0)
	END
   else 
	BEGIN
	   --Select retval = 1
	   Select @retval = 1
	   Return(0)
	END

GO

GRANT EXECUTE ON [Reservation_CheckLargeParty_ResoTime] TO ExecuteOnlyRole

GO
