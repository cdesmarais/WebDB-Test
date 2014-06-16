if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ChangeResoState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ChangeResoState]
GO




CREATE PROCEDURE dbo.Admin_ChangeResoState
@ReservationID int,
@state int

AS

BEGIN TRANSACTION
  Update Reservation
  Set RStateID = @state
  Where ResID = @ReservationID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_ChangeResoState] TO ExecuteOnlyRole

GO
