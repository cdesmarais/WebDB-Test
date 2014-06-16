if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ListPastPending]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ListPastPending]
GO

CREATE  Procedure dbo.Reservation_ListPastPending

As
--************************************
--** Legacy Proc
--************************************
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @now datetime
select @now= getdate() + 6 / 24.0

update Reservation set RStateID = 5 
where ResID in
(SELECT Reservation.ResID
FROM Reservation INNER JOIN
    Restaurant r ON 
    Reservation.RID = r.RID INNER JOIN
    TimeZone tz ON 
    r.TZID = tz.TZID 
WHERE (Reservation.RStateID = 1)
 and 2 + Reservation.ResTime + case
  when (2 + Reservation.ResTime) < 4 / 24.0
  then Reservation.ShiftDate + 1 else Reservation.ShiftDate
  end - tz._offsetHR / 24.0 < @now - 1.0 -- Allow 24 hours of slack.
and r.Allotment = 1)
 
SELECT top 500 Reservation.RStateID AS ReservationState,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    Reservation.ConfNumber AS ConfirmationNumber,
    Reservation.CustID AS UserID,
    Reservation.ShiftDate AS ReservationDate,
    Reservation.CallerID as CallerID,

    2 AS Version,
    Reservation.SeatedSize as Seated_Size,
    Reservation.PartySize as Party_Size,
    Reservation.ResID as Reservation_ID,
    (CASE
	WHEN Reservation.CallerID is null THEN 0
	ELSE 1
	END) as isCallerReso,
    Reservation.RID  as RID
 

FROM Reservation INNER JOIN
    RestaurantVW r ON 
    Reservation.RID = r.RID INNER JOIN
    TimeZone tz ON 
    r.TZID = tz.TZID INNER JOIN
    ERBRestaurant ON 
    r.RID = ERBRestaurant.RID
WHERE (Reservation.RStateID = 1)
 and 2 + Reservation.ResTime + case
  when (2 + Reservation.ResTime) < 4 / 24.0
  then Reservation.ShiftDate + 1 else Reservation.ShiftDate
  end - tz._offsetHR / 24.0 < @now - 1.0 -- Allow 24 hours of slack.
 and r.Allotment <> 1
 and  r.IsReachable = 1
GO

GRANT EXECUTE ON [Reservation_ListPastPending] TO ExecuteOnlyRole

GO
