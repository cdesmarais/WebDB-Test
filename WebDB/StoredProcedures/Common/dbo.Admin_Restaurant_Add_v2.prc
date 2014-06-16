if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Add_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Add_v2]
GO

--*******************************
--** TODO: EV: i18n: Review the use of StateID I don't think this should be in the Local table
--** TODO: EV: i18n: Add Name logging
--*******************************

CREATE Procedure dbo.Admin_Restaurant_Add_v2
(
    /*Restaurant*/
    @RestaurantName nvarchar(255),
    @MinOnlineOptionID int,
    @ParkingID int,
    @SmokingID int,
    @DressCodeID int,
    @PriceQuartileID int,
    @WalkinOptionID int,
    @NeighborhoodID int,
    @MinCCOptionID int,
    @MinTipSizeOptionID int,
    @MaxAdvanceOptionID int,
    @RestaurantStateID int,
    @DiningStyleID int,
    @Address1 nvarchar(255),
    @Address2 nvarchar(255),
    @City nvarchar(255),
    @StateID nvarchar(255),
    @PostalCode nvarchar(255),
    @CountryID char(2),
    @BanquetPhone nvarchar(24),
    @BusinessPhone nvarchar(24),
    @PrivatePartyPhone nvarchar(24),
    @ReservationPhone nvarchar(24),
    @FaxPhone nvarchar(24),
    @UpdatePassword nvarchar(20),
    @Chef nvarchar(255),
    @Email nvarchar(255),
    @ExternalURL nvarchar(255),
    @ReserveCode nvarchar(255),
    @BanquetContact nvarchar(255),
    @CrossStreet nvarchar(255),
    @PrivatePartyContact nvarchar(255),
    @Longitude dec(10,6) = NULL,
    @Latitude dec(10,6) = NULL,
    @HasGiftCertificate int,
    @GiftCertificateCode nvarchar(255),
    @HasBanquet int,
    @HasPrivateParty int,
    @HasCatering int,
    @Allotment int = 0,
    @ProductType int = 0,

    /*Erb_Restaurant*/
    @IPAddress nvarchar(255),
    @ServerPassword nvarchar(255),
    @ServerKey nvarchar(255),

     /*RestaurantDescriptions*/
    @CaterDescription nvarchar(600),
    @RestaurantDescription nvarchar(999),
    @Entertainment nvarchar(600),
    @ParkingDescription nvarchar(500),
    @PrivatePartyDescription nvarchar(999),
    @BanquetDescription nvarchar(999),
    /*RestaurantMessages*/
    @ConfirmationMessage nvarchar(999),
    /*RestaurantDescriptions*/
    @PublicTransit nvarchar(350),
    @Hours nvarchar(999),
    
    /*Food_Types*/
    @FoodTypes nvarchar(255),

    /*Offers*/
    @Offers nvarchar(255),

    /*PaymentTypes*/
    @PaymentTypes nvarchar(255),

    @Listener bit,
    
    @DynamicIP int=0,	
    @RestaurantSName nvarchar(255),

    @retval int OUTPUT
)

As

-- 
-- This v2 version initializes the new MinCCOnlineOption column (WR2009R4 TT 25524)
-- It continues to set the soon-to-be-depracated MaxOnlineOptionID
-- 

SET NOCOUNT ON
Declare @RestaurantID inT,@TZID int
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int

set @ProcName = 'Admin_Restaurant_Add'

--*******************************
--** Get Language
--*******************************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int
declare @DomainID int

select	top 1
		@LanguageID = LanguageID,
		@DomainID = DomainID
from DBUser 
where DBUser = User
-- When there is more than 1 domain give the lower DomainID priority (special case for US)
order by DomainID asc


SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

/*Check to see if the Reserve code is cool.  if not,taise an Error and bail*/
if exists (Select RID from Restaurant where ReserveCode = @ReserveCode)
	goto dupCode


Declare @StaticIPAddress int

Set @TZID = (Select TZID from MetroArea
inner join Neighborhood n on MetroArea.metroareaid = n.metroareaid
where n.neighborhoodid = @NeighborhoodID)

-- Static IP address setting..
Set @StaticIPAddress = 0
if @DynamicIP = 0 
BEGIN	
	-- if its not a dynamic IP, it is a static IP
	set @StaticIPAddress = 1
END

if @ProductType > 7
BEGIN
	Set @Listener = 0
END

--*******************************
--** Format Phone Number
--*******************************
set @Action = 'Format Phone Number'
exec PhoneValidate @BanquetPhone,@CountryID , 1, @BanquetPhone output
set @DBError = @@error
if @DBError <> 0
	goto error
exec PhoneValidate @BusinessPhone,@CountryID , 0, @BusinessPhone output
set @DBError = @@error
if @DBError <> 0
	goto error
exec PhoneValidate @PrivatePartyPhone,@CountryID , 1, @PrivatePartyPhone output
set @DBError = @@error
if @DBError <> 0
	goto error
exec PhoneValidate @ReservationPhone,@CountryID, 1, @ReservationPhone output
set @DBError = @@error
if @DBError <> 0
	goto error
exec PhoneValidate @FaxPhone,@CountryID, 1, @FaxPhone output
set @DBError = @@error
if @DBError <> 0
	goto error


--**************************************
--** Insert Record in Restaurant 
--**************************************
set @Action = 'Insert Record in Restaurant Table'
INSERT INTO Restaurant
(
	DomainID,
    r.RestaurantType,
    r.MinOnlineOptionID,
    r.ParkingID,
    r.SmokingID,
    DressCodeID,
    r.PriceQuartileID,
    r.WOID,
    r.TZID,
    r.neighborhoodid,
    r.MinCCOptionID,
    r.MinTipSizeOptionID,
    r.MaxAdvanceOptionID,
    r.RestStateID,
    DiningStyleID,
--    r.State, --TODO: EV: Review 
    r.Zip,
    r.Country,
    r.BanquetPhone,
    r.Phone,
    r.PrivatePartyPhone,
    r.ReservationPhone,
    r.FaxPhone,
    r.UpdatePwd,
    r.Email,
    r.ExternalURL,
    r.ReserveCode,
    r.HasBanquet,
    r.HasCatering,
    r.HasPrivateParty,
    r.Longitude,
    r.Latitude,
    r.HasGiftCertificate,
    r.GiftCertificateCode,
    r.Allotment,
    r.MaxLargePartyID,
    r.Ping,
    r.CCAccountStatusID,
    r.RomsModifiedDTUTC,
	r.MaxOnlineOptionID
)
VALUES
(
	@DomainID,
	(case when @Allotment = 1 then 'A' else 'E' end), /*Set the RestaurantType to ERB, Allotment, or Guestbridge */
    @MinOnlineOptionID,
    @ParkingID,
    @SmokingID,
    @DressCodeID,
    @PriceQuartileID,
    @WalkinOptionID,
    @TZID,
    @NeighborhoodID,
    @MinCCOptionID,
    @MinTipSizeOptionID,
    @MaxAdvanceOptionID,
    @RestaurantStateID,
    @DiningStyleID,
--    @StateID, --TODO: EV: i18n: Review
    @PostalCode,
    @CountryID,
    @BanquetPhone,
    @BusinessPhone,
    @PrivatePartyPhone,
    @ReservationPhone,
    @FaxPhone,
    @UpdatePassword,
    @Email,
    @ExternalURL,
    @ReserveCode,
    @HasBanquet,
    @HasCatering,
    @HasPrivateParty,
    @Longitude,
    @Latitude,
    @HasGiftCertificate,
    @GiftCertificateCode,
    @Allotment,
    @MinCCOptionID,
    @Listener,
    case WHEN @DomainID = 2 THEN 2 /*Opted Out*/ ELSE 1 /*default=No BT Action Taken*/ END,
    case WHEN @DomainID = 2 THEN GETUTCDATE() END, 
    CASE			-- maintain the MaxOnlineOptionID properly.  Normally MinCC-1, but handle endpoints specifically
		WHEN @MinCCOptionID = 20 THEN 20 
        WHEN @MinCCOptionID = 1 THEN 1
		ELSE @MinCCOptionID - 1 
	END
)set @DBError = @@error
if @DBError <> 0
		goto error

SELECT @RestaurantID = scope_identity()
set @DBError = @@error
if @DBError <> 0
		goto error


--**************************************
--** Insert Record into RestaurantLocal
--**************************************
set @Action = 'Insert RestaurantLocal'
insert into RestaurantLocal (
	RID,
	LanguageID,
    RName,
    RSName,
    Address1,
    Address2,
    City,
    State,
    Chef,
    BanquetContact,
    CrossStreet,
	PrivatePartyContact
	)
values (
	@RestaurantID,
	@LanguageID,
	@RestaurantName,
	rtrim(ltrim(@RestaurantSName)),
	@Address1,
	@Address2,
	@City,
	@StateID,
	@Chef,
	@BanquetContact,
	@CrossStreet,
	@PrivatePartyContact
)
set @DBError = @@error
if @DBError <> 0
		goto error


--**************************************
--** Log Name change
--**************************************
set @Action = 'Log Restaurant name change'
insert into RestNameChange
(RID, LanguageID, ResoRname, EffectiveDT)
values (@RestaurantID, @LanguageID, @RestaurantName, '01-01-1900') --default expireDT 01-01-9999
set @DBError = @@error
if @DBError <> 0
		goto error

--**************************************
--** Add ERB
--**************************************		
set @Action = 'Admin_ERBRestaurant_Add'
Exec Admin_ERBRestaurant_Add @RestaurantID = @RestaurantID,@ServerIP = @IPAddress,@ServerPassword = @ServerPassword,@ServerKey = @ServerKey,@ProductType = @ProductType, @StaticIPAddress = @StaticIPAddress
set @DBError = @@error
if @DBError <> 0
	goto error

Exec Admin_RestaurantMessage_Add @RestaurantID = @RestaurantID,@CaterDescription=@CaterDescription,@RestaurantMessage=@RestaurantDescription,
				        @Entertainment=@Entertainment,@ParkingDescription=@ParkingDescription,@PrivatePartyDescription=@PrivatePartyDescription,
			                      @BanquetDescription = @BanquetDescription,@ConfirmationMessage=@ConfirmationMessage,@PublicTransit=@PublicTransit,@Hours=@Hours
			                      set @DBError = @@error
if @DBError <> 0
	goto error

set @Action = 'Admin_FoodTypes_Add'
Exec Admin_FoodTypes_Add @RestaurantID=@RestaurantID,@FoodTypeID = @FoodTypes 
set @DBError = @@error
if @DBError <> 0
		goto error

set @Action = 'Admin_Offers_Add'
Exec Admin_Offers_Add @RestaurantID=@RestaurantID,@OfferID=@Offers
set @DBError = @@error
if @DBError <> 0
		goto error

set @Action = 'Admin_PaymentTypes_Add'
Exec Admin_PaymentTypes_Add @RestaurantID=@RestaurantID,@PaymentTypeID=@PaymentTypes 
set @DBError = @@error
if @DBError <> 0
		goto error


COMMIT TRANSACTION

--*************************************
--** SetValQueue for BT opted out
--*************************************
if (@DomainID = 2)
BEGIN
exec SvcSetValEnqueue @RestaurantID, 'PCI_Enabled', '0', 'AUTO - Opted out of Credit card Reservations.'
END




select @retval = @RestaurantID
Return(0)

error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(1)

dupCode:
	RAISERROR ('The Reservation code you have selected is already in use',16,1)
 	goto error
GO

GRANT EXECUTE ON [Admin_Restaurant_Add_v2] TO ExecuteOnlyRole

GO
