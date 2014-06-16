if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetResoStates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetResoStates]
GO




CREATE PROCEDURE dbo.Admin_GetResoStates
@curstate int
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN Transaction

Select ReservationState.RStateName as name,ReservationState.RStateID as reservation_state_id
from ReservationState
where RStateID <> @curstate
and  RStateID <>  6   --disputed
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_GetResoStates] TO ExecuteOnlyRole

GO
