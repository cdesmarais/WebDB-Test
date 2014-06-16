if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Reservation_ChangeState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Reservation_ChangeState]
GO




CREATE PROCEDURE dbo.Admin_Reservation_ChangeState

@ReservationID int,
@state int

AS
  Update Reservation
  Set RStateID = @state
  Where ResID = @ReservationID
GO

GRANT EXECUTE ON [Admin_Reservation_ChangeState] TO ExecuteOnlyRole

GO
