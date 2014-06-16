if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_Total]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_Total]
GO




CREATE PROCEDURE dbo.Concierge_Reservation_Caller_Total

	(
		@CallerID int
	)

As
SET NOCOUNT ON
SELECT Count(*) 
FROM Reservation
WHERE Reservation.CallerID = @CallerID
and Reservation.RStateID = 1
and CONVERT(nvarchar,ShiftDate,102) >= CONVERT(nvarchar,getdate(),102)
GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_Total] TO ExecuteOnlyRole

GO
