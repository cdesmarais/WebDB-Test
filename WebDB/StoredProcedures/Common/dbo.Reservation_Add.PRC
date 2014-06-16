if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_Add]
GO

CREATE Procedure dbo.Reservation_Add
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
  @retval nvarchar(255) OUTPUT
 )
As
SET NOCOUNT ON
declare @isAllotment as int,@SlotID int,@ShiftID int,@tempIDENT int,@tempPoints int
Declare @incentiveID as int,@tempval int

select @isAllotment = allotment from Restaurant where RID = @RestaurantID

Set  @ResDateTime = cast(@ResDateTime as datetime)
if @isAllotment <> 0 /*DO ALLOTMENT CHECKS ...*/
     BEGIN
		--**************************************
		-- ** Legacy APIs do not support allotment
		-- ** EV: 11/30/2009
		--**************************************
 		Raiserror ('87',17,2) /*'The Reservation slot you requested is no longer available'*/
		Return(1)
 	END


if @isAllotment = 0 --set default SlotID and ShiftID
   BEGIN
	set @SlotID = null
	set @ShiftID = 1

    /*Get Incentive AND POINTS INFORMATION ...*/

		Declare @IncentedPromo int
		Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where PromoID = @PromoID
		
		if @IncentedPromo = 1
		BEGIN
			exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentiveID OUTPUT
		END
		else
		BEGIN
			Set @incentiveID = null
		END

   END
	/*Get Points for Reso*/
	--IF @PromoID= 0 or @PromoID in (22,25,26,29,30,31,33)
	    Exec  Points_Calculate @PromoID,@ResDateTime,@RestaurantID,@PartySize,0,@points OUTPUT
	--ELSE  /*Promos override incentives  */
	 --  BEGIN
	  --     SET @Points = (Select Points from Promos where PromoID = @PromoID)
	  -- END
	   
	
	declare @LanguageID int
	select @LanguageID = LanguageID from RestaurantVW where rid = @RestaurantID

/*SET IDENTITY and RETVAL*/
EXEC [procGetResID] @tempIDENT output

/*INSERT INTO Reservation ...*/

	If @CallerID=0 (Select @CallerID=Null)
	If @CallerID>0 (Select @CallerID=@CallerID)
	INSERT INTO Reservation
    		(ResId,ShiftID,ShiftDate,RStateID,CallerID,CustID,ResTime,
    		PartySize,ContactPhone,DateMade,ConfNumber,SendReminder,ReminderSent,TimeSeated,SeatedSize,TimeCompleted,TimeArrived,
    		RID,CancelledDate,FirstTime,Business,PartnerID,CompanyID,incentiveid,ResPoints,UseDiningCheque,LargeParty,CreditCardID,
			CreditCardLastFour,Notes,ERBNotes,InviteMessage,LanguageID)
	VALUES (@tempIDENT,@ShiftID,CONVERT(nvarchar,@ResDateTime,102),1,@CallerID,@UserID,'12/30/1899 ' + CONVERT(nvarchar,@ResDateTime,108),
	    	@PartySize,@Phone,GETDATE(),@Confirmation,Null,0,Null,Null,Null,Null,
			@RestaurantID,Null,@FirstTime,@Business,@PartnerID,Null,@IncentiveID,@Points,@UseCheque,@LargeParty,Null,
			Null,@Notes,Null,Null,@LanguageID)

    	if @@error <> 0
		BEGIN
		Raiserror('85',16,1) --An Error occurred while adding the Reservation to our database.
		Return(2)
		END



/*ADD Restaurant to favorites list */

Exec FavoriteAutoUpdateForUser @UserID,@RestaurantID,@CallerID

	
	if @incentiveID is null
		SET @retval = cast(@tempIDENT as nvarchar(255))
	else
		SET @retval = 'i' + cast(@tempIDENT as nvarchar(255))

/*IF ALLOTMENT RESO ... insert into TemplateReservation*/if @isAllotment <> 0
     BEGIN
  	INSERT INTO TemplateReservation (ResID,SlotID,ShiftID,ShiftDate,RID)
  	VALUES (@tempIDENT,@SlotID,@ShiftID,CONVERT(nvarchar,@ResDateTime,110),@RestaurantID)

	if @@error <> 0
		BEGIN
		Raiserror('85',16,1) --An Error occurred while adding the Reservation to our database.
		Return(2)
		END
     END


/*  IF PROMO RESO ... insert one record into PromoReservations and one into PromoUse.   --drew 10-18-01 */if @PromoID <> 0 
    BEGIN
        Insert into PromoReservations (ResID,PromoID) values (@tempIDENT,@PromoID)

     
        IF @CallerID = 0
	set @CallerID = null /*this is to get around the fk constraint for CallerID in the PromoUse table   --drew 10-18-01 */
        Else
	set @UserID = null
        IF @UserID = 0
	set @UserID = null

        Insert into PromoUse(CustID,CallerID,PromoID,Points,RedeemDate,SiteID,ResID) values (@UserID,@CallerID,@PromoID,@Points,getdate(),1,@tempIDENT)  /*SiteID goes in as 1 because all the others in that table are 1 and no one know what the column is for.  --drew 10-19-01 */
    END
GO

GRANT EXECUTE ON [Reservation_Add] TO ExecuteOnlyRole

GO
