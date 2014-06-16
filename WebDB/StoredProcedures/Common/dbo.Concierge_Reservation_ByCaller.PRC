if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_ByCaller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_ByCaller]
GO

CREATE Procedure dbo.Concierge_Reservation_ByCaller
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT res.ShiftDate AS ResDate,
	 res.ResTime AS ResTime,
	 cc.LName + ',' + cc.FName AS GuestName,
	 r.RName AS RestaurantName,
	 r.Phone AS ContactPhone,
	 res.PartySize AS PartySize,
	 r.RID AS RestaurantID,
	 res.ResID AS ReservationID,
	 res.ShiftDate AS ReservationDate,
	 res.ResPoints as Points_For_Reservation
FROM Reservation res
INNER JOIN CallerCustomer cc
ON res.CustID=cc.CustID
INNER JOIN RestaurantVW r
ON res.RID=r.RID
WHERE (res.CallerID = @UserID) 
and res.RStateID = 1
and CONVERT(nvarchar,res.ShiftDate,102) >= CONVERT(nvarchar,getdate(),102)
ORDER BY 1,2

GO


GRANT EXECUTE ON [Concierge_Reservation_ByCaller] TO ExecuteOnlyRole

GO
