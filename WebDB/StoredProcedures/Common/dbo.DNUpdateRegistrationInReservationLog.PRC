if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateRegistrationInReservationLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateRegistrationInReservationLog]
GO

CREATE PROCEDURE dbo.DNUpdateRegistrationInReservationLog
(
   @SessionID nvarchar(24),
   @ReservationID int,
   @Registration int
)
 AS

SET NOCOUNT ON

/*
if EXISTS (select 1 from WebSiteReservationLog  WHERE SessionID = @SessionID AND ResID = @ReservationID)

UPDATE	 WebSiteReservationLog 
SET		 Registration = @Registration 
WHERE	 SessionID = @SessionID 
AND		 ResID = @ReservationID
*/
GO

GRANT EXECUTE ON [DNUpdateRegistrationInReservationLog] TO ExecuteOnlyRole

GO
