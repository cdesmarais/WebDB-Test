if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_setToBeCancelledNotificationStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_setToBeCancelledNotificationStatus]
GO

CREATE PROCEDURE dbo.Reservation_setToBeCancelledNotificationStatus
(@ReservationID integer
)
AS

SET NOCOUNT ON

Update ReservationsToBeCancelled
set CallCenterNotified = 1
where ResID = @ReservationID

GO

GRANT EXECUTE ON [Reservation_setToBeCancelledNotificationStatus] TO ExecuteOnlyRole

GO
