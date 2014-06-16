if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogReservation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogReservation]
GO


CREATE PROCEDURE dbo.DNLogReservation
(
      	@VisitorID nvarchar(24),
      	@SessionID nvarchar(24),
      	@UserID int,
      	@SearchType int,
      	@Registration int,
      	@ReservationID int,
      	@ReferralID int,
    	@PartnerID int,	
      	@UserType int
)
As

SET NOCOUNT ON
Declare @gobalError int

Begin Tran


if exists (select referrerID from referrer where referrerID = @ReferralID)
BEGIN
	Insert into referrerReservation (ReferrerID,ResID)
	VALUES (@ReferralID,@ReservationID)
	set @gobalError = @@ERROR
	IF @gobalError <> 0 GOTO ErrBlock
END

COMMIT

RETURN

ErrBlock:
ROLLBACK 
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = N'DNLogReservation Failed ' +
		N' @VisitorID: '+cast(ISNULL(@VisitorID,'') as nvarchar(20))+ N' @SessionID: '+ cast(ISNULL(@SessionID, '') as nvarchar(20)) +N' @UserID: '+cast(ISNULL(@UserID, '') as nvarchar(10))+ 
		N' @SearchType: '+cast(ISNULL(@SearchType,'') as nvarchar(10))+N' @Registration: '+cast(ISNULL(@Registration, '') as nvarchar(10))+N' @ReservationID: '+cast(ISNULL(@ReservationID, '') as nvarchar(10))+
		N' @ReferralID: '+cast(ISNULL(@ReferralID, '') as nvarchar(10))+N' @PartnerID: '+cast(ISNULL(@PartnerID, '') as nvarchar(10))+N' @UserType: '+cast(ISNULL(@UserType, '') as nvarchar(10))
	exec DNErrorAdd 555, 'DNLogReservation', @ErrorMsg, 1

RETURN 


GO


GRANT EXECUTE ON [DNLogReservation] TO ExecuteOnlyRole

GO
