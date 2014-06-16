if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantCheckNearDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantCheckNearDay]
GO






CREATE Procedure dbo.RestaurantCheckNearDay
 (
  @RestaurantID int,
  @ResDate datetime,
  @CustomerID int,
  @retval nvarchar(999) output
 )
As
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE
if exists(Select ResID,DATEDIFF(day,ShiftDate,@ResDate) AS no_of_days
from Reservation
where RID = @RestaurantID and CustID = @CustomerID and RStateID = 1
group by ResID,DATEDIFF(day,ShiftDate,@ResDate)
having DATEDIFF(day,ShiftDate,@ResDate) < 4 and DATEDIFF(day,ShiftDate,@ResDate) > -4)
BEGIN
Select @retval = 'Thank you for your interest in The French Laundry.  We ask that only one Reservation be made within 3 days.  Please cancel your existing Reservation first before booking.  We regret any inconvenience and greatly appreciate your business.'
END
else
BEGIN
Select @retval = ''
END
GO

GRANT EXECUTE ON [RestaurantCheckNearDay] TO ExecuteOnlyRole

GO
