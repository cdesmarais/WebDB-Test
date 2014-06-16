if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_SaveReferrer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_SaveReferrer]
GO



CREATE Procedure dbo.Reservation_SaveReferrer 
(
@ReferrerID int,
@RestaurantID int,
@retval int OUTPUT
)

AS
SET NOCOUNT ON
Declare @gobalError int

Begin Tran

if exists (select referrerID from referrer where referrerID = @ReferrerID)
BEGIN
	Insert into ReferrerReservation (ReferrerID,ResID)
	values (@ReferrerID,@RestaurantID)
	set @gobalError = @@ERROR
	IF @gobalError <> 0 GOTO nogood
END

SELECT @retval= 1
	commit
RETURN(1)

nogood:
Rollback

declare @ErrorMsg as nvarchar(4000)
set @ErrorMsg = ' @ReferrerID : '+ cast(ISNULL(@ReferrerID, '')  as nvarchar(20)) +' @RestaurantID : '+cast(ISNULL(@RestaurantID, '') as nvarchar(10)) + ' Error: ' + convert(nvarchar, @gobalError)
exec DNErrorAdd 555, 'Reservation_SaveReferrer', @ErrorMsg , 1

RETURN(0)

GO


GRANT EXECUTE ON [Reservation_SaveReferrer] TO ExecuteOnlyRole

GO
