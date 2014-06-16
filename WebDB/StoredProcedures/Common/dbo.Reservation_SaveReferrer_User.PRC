if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_SaveReferrer_User]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_SaveReferrer_User]
GO




CREATE PROCEDURE dbo.Reservation_SaveReferrer_User
(
@Referring_CustomerID nvarchar(255),
@Referring_CallerID int,
@ReservationID int,
@retval int OUTPUT
)
AS
SET NOCOUNT ON

Insert into ReferrerUserReservation (ReferringCustID,ReferringCallerID,ResID)
values (@Referring_CustomerID,@Referring_CallerID,@ReservationID)
     if (@@error <> 0) goto nogood
SELECT @retval= 1
RETURN(1)
nogood:
RETURN(0)
GO

GRANT EXECUTE ON [Reservation_SaveReferrer_User] TO ExecuteOnlyRole

GO
