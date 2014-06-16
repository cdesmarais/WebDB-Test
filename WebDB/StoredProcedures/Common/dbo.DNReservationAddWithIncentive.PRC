
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationAddWithIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationAddWithIncentive]
GO


CREATE Procedure dbo.DNReservationAddWithIncentive
 (
  @ResDateTime datetime,
  @UserID int,
  @PartySize int,
  @Phone nvarchar(24),
  @Notes nvarchar(999),
  @Confirmation nvarchar(255),
  @RestaurantID int,
  @Business tinyint,
  @FirstTime tinyint,
  @PartnerID int,
  @Points int,--the points for reso are re-calculated in this stored proc!
  @UseCheque int,
  @CallerID int=0,
  @LargeParty bit = 0,
  @PromoID int = 0,
  @CCLast4 char(4),
  @IncentiveID int = 0,
  @ErbNotes nvarchar(255) = null,
  @retval nvarchar(255) OUTPUT
 )
As
/*build 10/21/2003 ... moved gathering of @tempIdentity value to before adding of favorites*/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
declare @ShiftID int,@tempIDENT int,@CompanyID int

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
set @ProcName = 'DNReservationAddWithIncentive'

Set  @ResDateTime = cast(@ResDateTime as datetime)

if @PartnerID = 0
BEGIN
	Set @PartnerID = 1
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = N'DNReservationAddWithIncentive Had a Bad PartnerID ' +
		N' @Confirmation: '+cast(ISNULL(@Confirmation,'') as nvarchar(20))+ 
		N' @RestaurantID: '+ cast(ISNULL(@RestaurantID, '') as nvarchar(10))
	exec DNErrorAdd 556, 'DNReservationAddWithIncentive', @ErrorMsg, 1
END

if @IncentiveID = 0
BEGIN
	Set @IncentiveID = null
END

set @ShiftID = 1

/*INSERT INTO Reservation ...*/

If @CallerID=0 (Select @CallerID=Null)

If @CallerID>0 
BEGIN
	Select @CompanyID = CompanyID from caller where callerID = @CallerID
END

declare @LanguageID int

--**************************
--** Retrieve language and Domain info based on the Restaurant the reso is being made for
--**************************
select	@LanguageId = LanguageId
from	RestaurantVW r
where   r.RID = @RestaurantID

/*SET IDENTITY */
EXEC [procGetResID] @tempIDENT output


--**********************
--** INSERT INTO Reservation
--**********************
set @Action = 'INSERT INTO Reservation'

INSERT INTO Reservation
		(ResId,ShiftID,ShiftDate,RStateID,CallerID,CustID,ResTime,
		PartySize,ContactPhone,DateMade,ConfNumber,SendReminder,ReminderSent,TimeSeated,SeatedSize,TimeCompleted,TimeArrived,
		RID,CancelledDate,FirstTime,Business,PartnerID,CompanyID,incentiveid,ResPoints,UseDiningCheque,LargeParty,CreditCardID,
		CreditCardLastFour,Notes,ERBNotes,InviteMessage,LanguageID)
VALUES (@tempIDENT,@ShiftID,CONVERT(nvarchar,@ResDateTime,102),1,@CallerID,@UserID,'12/30/1899 ' + CONVERT(nvarchar,@ResDateTime,108),
		@PartySize,@Phone,GETDATE(),@Confirmation,Null,0,Null,Null,Null,Null,
		@RestaurantID,Null,@FirstTime,@Business,@PartnerID,@CompanyID,@IncentiveID,@Points,0,@LargeParty,Null,
		@CCLast4,@Notes,@ErbNotes,Null,@LanguageID)

set @DBError = @@error
if @DBError <> 0
	goto general_error

/*SET RETVAL*/
SET @retval = cast(@tempIDENT as nvarchar(255))

--**********************
--** ADD Restaurant to favorites list
--**********************
set @Action = 'Exec FavoriteAutoUpdateForUser'
Exec FavoriteAutoUpdateForUser @UserID,@RestaurantID,@CallerID
set @DBError = @@error
if @DBError <> 0
	goto general_error

/*  IF PROMO RESO ... insert one record into PromoReservations and one into PromoUse.   --drew 10-18-01 */
if @PromoID <> 0 
    BEGIN
		--**********************
		--** Insert into PromoReservations
		--**********************
		set @Action = 'Insert into PromoReservations'
    
        Insert into PromoReservations (ResID,PromoID) values (@tempIDENT,@PromoID)
        set @DBError = @@error
		if @DBError <> 0
			goto general_error

        IF @CallerID = 0
			set @CallerID = null /*this is to get around the fk constraint for CallerID in the PromoUse table   --drew 10-18-01 */
        Else
			set @UserID = null
        IF @UserID = 0
			set @UserID = null

		--**********************
		--** Insert into PromoUse
		--**********************
		set @Action = 'Insert into PromoUse'

        Insert into PromoUse(CustID,CallerID,PromoID,Points,RedeemDate,SiteID,ResID) values (@UserID,@CallerID,@PromoID,@Points,getdate(),1,@tempIDENT)  /*SiteID goes in as 1 because all the others in that table are 1 and no one know what the column is for.  --drew 10-19-01 */
        set @DBError = @@error
		if @DBError <> 0
			goto general_error

    END


RETURN(0)

general_error:
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Raiserror('85',16,1) --An Error occurred while adding the Reservation to our database.
	RETURN(2)
GO



GRANT EXECUTE ON [DNReservationAddWithIncentive] TO ExecuteOnlyRole

GO

