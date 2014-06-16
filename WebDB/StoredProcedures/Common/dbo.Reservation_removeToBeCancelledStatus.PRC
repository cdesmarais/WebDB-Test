if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_removeToBeCancelledStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_removeToBeCancelledStatus]
GO



CREATE Procedure dbo.Reservation_removeToBeCancelledStatus
(@ReservationID int
)
 AS
 SET NOCOUNT ON
delete from ReservationsToBeCancelled
WHERE ResID = @ReservationID
GO

GRANT EXECUTE ON [Reservation_removeToBeCancelledStatus] TO ExecuteOnlyRole

GO
