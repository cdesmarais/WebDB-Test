if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_setToBeCancelledAtERB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_setToBeCancelledAtERB]
GO

CREATE PROCEDURE dbo.Reservation_setToBeCancelledAtERB
(
@ReservationID int
)
AS

SET NOCOUNT ON
 
--****************
--** Proc has been changed to use CancelQueue 
--** Other procs that use ReservationToBeCanclled are now obsolete
--****************
if not exists(select ResID from CancelQueue where ResID = @ReservationID) 
begin
	insert into CancelQueue (ResID)
	Values (@ReservationID)
end

GO


GRANT EXECUTE ON [Reservation_setToBeCancelledAtERB] TO ExecuteOnlyRole

GO
