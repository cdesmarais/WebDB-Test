if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_CountbyDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_CountbyDate]
GO




CREATE PROCEDURE dbo.Concierge_Reservation_Caller_CountbyDate
	(
		@CallerID int,
		@DateMade datetime
	)
As
SET NOCOUNT ON
	SELECT Count(*)
	FROM Reservation
	WHERE Reservation.CallerID = @CallerID AND
	Reservation.DateMade = @DateMade
GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_CountbyDate] TO ExecuteOnlyRole

GO
