if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Call_Add_WithCC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Call_Add_WithCC]
GO

CREATE Procedure dbo.Concierge_Reservation_Call_Add_WithCC
 (
  @ResDateTime datetime,
  @UserID int,
  @CallerID int,
  @PartySize int,
  @Phone nvarchar(24),
  @Notes nvarchar(999),
  @Confirmation nvarchar(255),
  @RestaurantID int,
  @Business tinyint,
  @FirstTime tinyint,
  @PartnerID int,
  @Points int,
  @LargeParty bit,
  @PromoID int = 0,
  @CCNumber nvarchar(4),
  @retval int OUTPUT
 )
As

--***************************************************
--This proc has been deprecated.
--***************************************************



--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
declare @isAllotment as int
      ,@SlotID int
      ,@ShiftID int
      ,@tempIDENT int
      ,@tempPoints int
      ,@isblocked int


declare @LanguageID int
select @isAllotment = allotment, @LanguageID = LanguageID from RestaurantVW where RID = @RestaurantID

DECLARE @HotelID int

--Get the Company ID from Caller

SELECT @HotelID=CompanyID from Caller Where CallerID=@CallerID


if @isAllotment <> 0 /*DO ALLOTMENT CHECKS ...*/
     BEGIN
        --** Legacy pre-console allotment no longer supported (2007)
 		Raiserror ('87',17,2) /*'The Reservation slot you requested is no longer available'*/
		Return(1)
 	END

if @isAllotment = 0 --set default SlotID and ShiftID
  BEGIN
	set @SlotID = null
	set @ShiftID = 1
	--END

/*Get Incentive AND POINTS INFORMATION ...*/

	Declare @IncentedPromo int
	Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where PromoID = @PromoID
	
	if @IncentedPromo = 1
	BEGIN
		Declare @incentiveID as int,@tempval int
		
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
	
		Exec ConciergeHotelBlockedRestaurant @HotelID,@RestaurantID,@isblocked OUTPUT
		if @isblocked = 1
		BEGIN

			Set @points = 0
		END

		
	--ELSE  /*Promos override incentives  */
	--BEGIN
	--	SET @Points = (Select Points from Promos where PromoID = @PromoID)
	--END

	/*Get Points for Reso*/
	/*
	if @incentiveID is null
	BEGIN
		if @ResDateTime < '9/1/2002'
		BEGIN
            			set @points = '200' -- date promo points
		END
		else
		BEGIN
			if @PromoID > 0
			BEGIN
				SET @Points = (Select Points from Promos where PromoID = @PromoID)            			

			END
			else
			BEGIN
				set @points = '100' -- min point value for a reso ... until business rule changes
			END
		END
	END
	*/	
	--set @Points = 100

	--if @incentiveID is not null
	--BEGIN
		--select @tempPoints = amount from  Incentive where incentiveid = @incentiveID
	 	--if @tempPoints is not null
 	 	--set @Points = (@tempPoints * @PartySize)
	 	--else
		--BEGIN
		--	if @ResDateTime < '5/1/2002'
		--	BEGIN
	            	--		set @points = '200' -- date promo points
		--	END
		--	else
		--	BEGIN
	            		--	set @points = '100' -- min point value for a reso ... until business rule changes
		--	END
		--END
		--  set @points = 100 -- min point value for a reso ... until business rule changes
	--END

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
		@RestaurantID,Null,@FirstTime,@Business,@PartnerID,@HotelID,@IncentiveID,@Points,0,@LargeParty,Null,
		@CCNumber,@Notes,Null,Null,@LanguageID)

	

    	if @@error <> 0
		BEGIN
		Raiserror('85',16,1) --An Error occurred while adding the Reservation to our database.
		Return(2)
		END



	--if @incentiveID is null
		SET @retval = cast(@tempIDENT as nvarchar(255))
	--else
	--	SET @retval = 'i' + cast(@tempIDENT as nvarchar(255))

/*IF ALLOTMENT RESO ... insert into TemplateReservation*/
if @isAllotment <> 0
     BEGIN
  	INSERT INTO TemplateReservation (ResID,SlotID,ShiftID,ShiftDate,RID)
  	VALUES (@tempIDENT,@SlotID,@ShiftID,CONVERT(nvarchar,@ResDateTime,110),@RestaurantID)

	if @@error <> 0
		BEGIN
		Raiserror('85',16,1) --An Error occurred while adding the Reservation to our database.
		Return(2)
		END
     END

/* Set Partner Referral */

if (@HotelID = 1283) or (@HotelID = 968)
BEGIN
	Insert into referrerRestaurantreservation (RID, RESID, HasPoints)
	VALUES (@RestaurantID, @tempIDENT, (case when @points = 0 then 0 else 1 end))

END

/*  IF PROMO RESO ... insert one record into PromoReservations and one into PromoUse.   --drew 10-18-01 */
if @PromoID <> 0 
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


GRANT EXECUTE ON [Concierge_Reservation_Call_Add_WithCC] TO ExecuteOnlyRole

GO
