if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ListByUserID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ListByUserID]
GO

CREATE Procedure dbo.Reservation_ListByUserID
 (
  @UserID int,
  @IsCaller int=0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @ServerTZID as int

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT
if @IsCaller=0 

BEGIN
SELECT 
			 Reservation.ResID AS ReservationID
			,Reservation.ShiftDate + 2 + Reservation.ResTime AS ReservationDateTime
			,r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,r.City
			,r.State
			,Reservation.RStateID AS ReservationState
			,ResPoints as Points
			,PartySize as PartySize
			,tz._offsetHR
FROM		 Reservation 
INNER JOIN	 RestaurantVW r 
ON			 Reservation.RID = r.RID 
INNER JOIN	 TimeZone tz 
ON			 r.TZID = tz.TZID
WHERE		 Reservation.CustID=@UserID
AND			 Reservation.RStateID = 1
AND (dateadd(Hour,((select _offsetHR from TimeZone where TZID = r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()) ) <= (Reservation.ShiftDate + 2 + Reservation.ResTime)
order by	 ReservationDateTime
END

if @IsCaller=1

BEGIN
SELECT 
			 Reservation.ResID AS ReservationID
			,Reservation.ShiftDate + 2 + Reservation.ResTime AS ReservationDateTime
			,r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,r.City
			,r.State
			,Reservation.RStateID AS ReservationState
			,ResPoints as Points
			,PartySize as PartySize
			,tz._offsetHR
FROM		Reservation 
INNER JOIN	RestaurantVW r 
ON			Reservation.RID = r.RID 
INNER JOIN	TimeZone tz 
ON			r.TZID = tz.TZID
WHERE 	Reservation.CallerID=@UserID
and (Reservation.RStateID = 1)
AND (dateadd(Hour,((select _offsetHR from TimeZone where TZID = r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()) ) <= (Reservation.ShiftDate + 2 + Reservation.ResTime)
order by ReservationDateTime
END
GO

GRANT EXECUTE ON [Reservation_ListByUserID] TO ExecuteOnlyRole

GO
