if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_SetReminderSentField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_SetReminderSentField]
GO

CREATE Procedure dbo.Reservation_SetReminderSentField
(
@ReservationID int
)

 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

insert ReminderSentLog (resid) values (@ReservationID)

GO

GRANT EXECUTE ON [Reservation_SetReminderSentField] TO ExecuteOnlyRole

GO
