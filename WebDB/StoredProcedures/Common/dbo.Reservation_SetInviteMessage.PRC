if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_SetInviteMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_SetInviteMessage]
GO

CREATE Procedure dbo.Reservation_SetInviteMessage
 (
  @ReservationID int,
  @Message nvarchar(999)
 )
As
SET NOCOUNT ON
UPDATE Reservation
SET InviteMessage = @Message
WHERE (ResID = @ReservationID)

GO

GRANT EXECUTE ON [Reservation_SetInviteMessage] TO ExecuteOnlyRole

GO
