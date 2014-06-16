if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Update]
GO
  


CREATE Procedure dbo.Admin_Restaurant_Update
(  
 /*Restaurant*/  
    @RestaurantID int,  
    @RestaurantName nvarchar(255),  
    @MinOnlineOptionID int,  
    @ParkingID int,  
    @SmokingID int,  
    @DressCodeID int,  
    @PriceQuartileID int,  
    @WalkinOptionID int,  
    @NeighborhoodID int,  
    @MaxOnlineOptionID int,  
    @MinTipSizeOptionID int,  
    @MaxAdvanceOptionID int,  
    @RestaurantStateID int,  
    @DiningStyleID int,  
    @Address1 nvarchar(255),  
    @Address2 nvarchar(255),  
    @City nvarchar(255),  
    @State nvarchar(255),  
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
    @ProductType int,  
  
    /*Erb_Restaurant*/  
    @ServerIPAddress nvarchar(255),  
    @ServerPass nvarchar(255),  
    @ServerKey nvarchar(255),  
  
    /*Restaurant_Message*/  
    @CaterDescription nvarchar(600),  
    @RestaurantDescription nvarchar(999),  
    @Entertainment nvarchar(600),  
    @ParkingDescription nvarchar(500),  
    @PrivatePartyDescription nvarchar(999),  
    @BanquetDescription nvarchar(999),  
    @ConfirmationMessage nvarchar(999),  
    @PublicTransit nvarchar(350),  
    @Hours nvarchar(999),  
  
     /*FoodTypes*/  
    @FoodTypes nvarchar(255),  
  
    /*Offers*/  
    @Offers nvarchar(255),  
  
    /*PaymentTypes*/  
    @PaymentTypes nvarchar(255),  
  
    @Listener bit,  
  
    @NetVisits int,  
    @DynamicIP int=0,   
    @LanguageID int=1,  
    @RestaurantSName nvarchar(255)  
)  
As  
SET NOCOUNT ON  
  
declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int 
set @ProcName = 'Admin_Restaurant_Update'  
set @Action = 'Proc Started'  
  
BEGIN TRANSACTION  
  
--***************************  
--** Retrieve LanguageID  
--***************************  
set @Action = 'Retrieve LanguageID'  
exec @LanguageID = procGetDBUserLanguageID  
set @DBError = @@error  
if @DBError <> 0  
 goto error  
  
  
Declare @Allotment int
if @ProductType = 2 or @ProductType = 3 or @ProductType = 4  
BEGIN
	set @Allotment = 1  
END
else  
BEGIN
	set @Allotment = 0  
END
  
Declare @RealTimeZoneID int, @StaticIPAddress int
  
Select		@RealTimeZoneID = TZID 
from		MetroArea
inner join	Neighborhood on MetroArea.MetroAreaID = Neighborhood.MetroAreaID
where		Neighborhood.NeighborhoodID = @NeighborhoodID
  
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
  
--***************************  
--Format Phone numbers  
--***************************  
set @Action = 'Format Phone numbers'  
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
  
IF @RestaurantName <> (select R.Rname from RestaurantVW R where R.RID = @RestaurantID)
	Begin
		set @Action = 'Restaurant Name Changed'  
    
		Declare @ExpireDT datetime
		Set @ExpireDT = getdate()	
   
		Update	RestNameChange		--Expire/Version Old RNAME 
		SET		ExpireDT = @ExpireDT
		where	RID = @RestaurantID
			and  LanguageID = @LanguageID  
			and  ExpireDT > @ExpireDT   
	  
		set @DBError = @@error  
		if @DBError <> 0  
			goto error  
	  
		insert into RestNameChange --Insert new Rname with a new record  
		(RID, LanguageID, ResoRname, EffectiveDT)
		values (@RestaurantID, @LanguageID, @RestaurantName, @ExpireDT)
	    
		set @DBError = @@error  
		if @DBError <> 0  
			goto error  
	END
  
set @Action = 'Update Restaurant Local'  
UPDATE RestaurantLocal
SET
	RName = @RestaurantName,  
	RSName = rtrim(ltrim(@RestaurantSName)),  
	Address1 = @Address1,  
	Address2 = @Address2,  
	City = @City,  
	State = @State,  
	Chef = @Chef,  
	BanquetContact = @BanquetContact,  
	CrossStreet = @CrossStreet,  
	PrivatePartyContact = @PrivatePartyContact,  
	IsActive = 1
WHERE	rid = @RestaurantID
	and  LanguageID = @LanguageID  
  
--Update View... This will fail if View attempts to update more than 1 table  
set @Action = 'Update RestaurantVW'  
UPDATE RestaurantVW
SET
	MinOnlineOptionID = @MinOnlineOptionID,  
	ParkingID = @ParkingID,  
	SmokingID = @SmokingID,  
	DressCodeID = @DressCodeID,  
	PriceQuartileID = @PriceQuartileID,  
	WOID = @WalkinOptionID,  
	TZID = @RealTimeZoneID,  
	NeighborhoodID = @NeighborhoodID,  
	MaxOnlineOptionID = @MaxOnlineOptionID,  
	MinTipSizeOptionID = @MinTipSizeOptionID,  
	MaxAdvanceOptionID = @MaxAdvanceOptionID,  
	RestStateID = @RestaurantStateID,  
	DiningStyleID = @DiningStyleID,  
	Zip = @PostalCode,  
	Country = @CountryID,  
	BanquetPhone = @BanquetPhone,  
	Phone = @BusinessPhone,  
	PrivatePartyPhone = @PrivatePartyPhone,  
	ReservationPhone = @ReservationPhone,  
	FaxPhone = @Faxphone,  
	UpdatePwd = @UpdatePassword,  
	Email = @Email,  
	ExternalURL = @ExternalURL,  
	ReserveCode = @ReserveCode,  
	HasBanquet = @HasBanquet,  
	HasCatering = @HasCatering,  
	HasPrivateParty = @HasPrivateParty,  
	Longitude = @Longitude,  
	Latitude = @Latitude,  
	HasGiftCertificate = @HasGiftCertificate,  
	GiftCertificateCode = @GiftCertificateCode,  
	Allotment = @Allotment,  
	Ping = @Listener  
  
WHERE (RID = @RestaurantID)
set @DBError = @@error  
if @DBError <> 0  
 goto error  

-- update Restaurant ERB infromation and update the status of ERBLockFromROMS 
-- flag as per the current restaurant status.
set @Action = 'Update Admin_ERBRestaurant_Update'  
EXEC dbo.Admin_ERBRestaurant_Update @RestaurantID=@RestaurantID, @ServerIP=@ServerIPAddress, @ServerPassword=@ServerPass, @ServerKey=@ServerKey, @ProductType = @ProductType, @StaticIPAddress = @StaticIPAddress,@RestaurantStateID=@RestaurantStateID  
set @DBError = @@error  
if @DBError <> 0  
 goto error  
  
set @Action = 'Update Admin_RestaurantMessage_Update'  
EXEC dbo.Admin_RestaurantMessage_Update @RestaurantID=@RestaurantID, @LanguageID=@LanguageID, @CaterDescription=@CaterDescription, @RestaurantMessage=@RestaurantDescription, @Entertainment=@Entertainment, @ParkingDescription=@ParkingDescription, @PrivatePartyDescription=@PrivatePartyDescription, @BanquetDescription=@BanquetDescription, @ConfirmationMessage=@ConfirmationMessage, @PublicTransit=@PublicTransit, @Hours=@Hours
set @DBError = @@error  
if @DBError <> 0  
 goto error  
  
set @Action = 'Update FoodTypes'  
EXEC dbo.Admin_FoodTypes_Delete @RestaurantID = @RestaurantID
EXEC dbo.Admin_FoodTypes_Add @RestaurantID = @RestaurantID, @FoodTypeID =  @FoodTypes
set @DBError = @@error  
if @DBError <> 0  
 goto error  
  
set @Action = 'Update Offers'  
Exec dbo.Admin_Offers_Delete @RestaurantID = @RestaurantID
Exec dbo.Admin_Offers_Add @RestaurantID=@RestaurantID, @OfferID=@Offers
set @DBError = @@error  
if @DBError <> 0  
  goto error  
  
set @Action = 'Update Payments'  
Exec dbo.Admin_PaymentTypes_Delete @RestaurantID = @RestaurantID
Exec dbo.Admin_PaymentTypes_Add @RestaurantID=@RestaurantID, @PaymentTypeID=@PaymentTypes
set @DBError = @@error  
if @DBError <> 0  
  goto error  
  
set @Action = 'Update RestaurantNetvisit'  
Delete from RestaurantNetvisit where RID = @RestaurantID
if @NetVisits <> 0  
BEGIN
	Insert into RestaurantNetvisit (RID, NetVisitID) 
	VALUES(@RestaurantID,@NetVisits)
END
  
--Set DIP Status of the restaurant based on Restaurant's State  
set @Action = 'Incentive_SetRestIncentiveStatus'  
Exec dbo.Incentive_SetRestIncentiveStatus @RestaurantID, @RestaurantStateID
  
COMMIT TRANSACTION  
Return(0)  
  
error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1)  
  
GO


GRANT EXECUTE ON [Admin_Restaurant_Update] TO ExecuteOnlyRole

GO




