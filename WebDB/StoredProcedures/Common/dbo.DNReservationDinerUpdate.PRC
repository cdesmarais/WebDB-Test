if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationDinerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationDinerUpdate]
GO


CREATE PROCEDURE dbo.DNReservationDinerUpdate
(
@Caller_ID int,
@ReservationID int,
@DinerID int
)
AS
SET NOCOUNT ON

DECLARE @retval int,@CustID int

BEGIN TRANSACTION  UpdateTran


Update Reservation set CustID = @DinerID where ResID = @ReservationID and CallerID = @Caller_ID


COMMIT TRANSACTION UpdateTran 
Return(0)

general_error:
ROLLBACK TRANSACTION  UpdateTran 
RAISERROR('7',17,1)
RETURN(2)
GO

GRANT EXECUTE ON [DNReservationDinerUpdate] TO ExecuteOnlyRole

GO
