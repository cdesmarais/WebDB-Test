
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_Restaurant_UpdateInfo1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_Restaurant_UpdateInfo1]
GO


CREATE PROCEDURE [dbo].[OTR_Restaurant_UpdateInfo1]
(
	@RestaurantID int,
	@LanguageID int,
	@CrossStreet nvarchar(150),
	@Phone varchar(24),
	@StyleID int,
	@FoodTypes nvarchar(255),
	@PriceQuartileID int,
	@Hours nvarchar(999),
	@Description nvarchar(999),
	@WebAddress nvarchar(256),
	@Email nvarchar(510),
	@MenuLink nvarchar(500),
	@TwitterAcctName nvarchar(50),
	@FacebookURL nvarchar(250),
	@PaymentOptions nvarchar(255),
	@DressCodeID int,
	@WalkinID int,
	@Offers nvarchar(255),
	@ConfirmationMessage nvarchar(999),
	@Chef nvarchar(255),
	@Entertainment nvarchar(999),
	@Parking int,
	@ParkingOption nvarchar(1998),
	@PublicTransport nvarchar(1998),
	@CateringOptions nvarchar(1998),
	@SpecialEvents nvarchar(999),
	@SpecialEventStartDate datetime,
	@SpecialEventEndDate datetime,
	@PrivatePartyContact nvarchar(50),
	@PrivatePartyPhone varchar(20),
	@PrivatePartyCapacity int,
	@PrivatePartyDescription nvarchar(1998)
)

AS

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int

set @ProcName = 'OTR_Restaurant_UpdateInfo1'
set @Action = 'Proc Started'

BEGIN TRANSACTION

set @Action = 'update RestaurantLocal'
update [RestaurantLocal]
	set	[CrossStreet] = @CrossStreet,
		[Chef] = @Chef,
		[PrivatePartyContact] = @PrivatePartyContact
	where	[RID] = @RestaurantID
		and	[LanguageID] = @LanguageID

set @DBError = @@error
if @DBError <> 0
	goto error

set @Action = 'update Restaurant' 
update [Restaurant]
	set	[ReservationPhone] = @Phone,
		[Phone] = @Phone,
		[DressCodeID] = @DressCodeID,
		[PriceQuartileID] = @PriceQuartileID,
		[WOID] = @WalkinID,
		[DiningStyleID] = @StyleID,
		[ParkingID] = @Parking,
		[ExternalURL] = @WebAddress,
		[Email] = @Email,
		[MenuURL] = @MenuLink,
		[TwitterAccountName] = @TwitterAcctName,
		[FacebookURL] = @FacebookURL,
		[PrivatePartyPhone] = @PrivatePartyPhone,
		[LargestCapacity] = @PrivatePartyCapacity
	where	[RID] = @RestaurantID

set @DBError = @@error
if @DBError <> 0
	goto error

set @Action = 'Update FoodTypes'
EXEC dbo.Admin_FoodTypes_ChangeForLanguage @RestaurantID = @RestaurantID, @LanguageID = @LanguageID, @FoodTypeID =  @FoodTypes
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
Exec dbo.Admin_PaymentTypes_Add @RestaurantID=@RestaurantID, @PaymentTypeID=@PaymentOptions
set @DBError = @@error
if @DBError <> 0  
	goto error 

set @Action = 'Update Restaurant Description Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'RestaurantDescription',@Description
set @DBError = @@error  
if @DBError <> 0  
	goto error  

set @Action = 'Update Hours Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'Hours',@Hours
set @DBError = @@error  
if @DBError <> 0  
	goto error  

set @Action = 'Update Confirmation Message'
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'Confirmation',@ConfirmationMessage
set @DBError = @@error  
if @DBError <> 0  
	goto error  

set @Action = 'Update Entertainment Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'Entertainment',@Entertainment
set @DBError = @@error  
if @DBError <> 0  
	goto error

set @Action = 'Update Parking Description Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'ParkingDescription',@ParkingOption
set @DBError = @@error  
if @DBError <> 0  
	goto error

set @Action = 'Update Public Transit Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'PublicTransit',@PublicTransport
set @DBError = @@error  
if @DBError <> 0  
	goto error

set @Action = 'Update Catering Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'CaterDescription',@CateringOptions
set @DBError = @@error  
if @DBError <> 0  
	goto error
	
set @Action = 'Update Private Party Message'  
exec DNRestaurantSetCustomMessageFromNameForLanguage @RestaurantID,@LanguageID,'PrivatePartyDescription',@PrivatePartyDescription
set @DBError = @@error  
if @DBError <> 0  
	goto error

set @Action = 'Update Special Events message'
exec DNRestaurantSetCustomMessageWithDatesFromNameForLanguage @RestaurantID,@LanguageID,'SpecialEvents',@SpecialEvents, @SpecialEventStartDate, @SpecialEventEndDate
set @DBError = @@error  
if @DBError <> 0  
	goto error  

COMMIT TRANSACTION  
Return(0)  
  
error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1)  
  
GO

GRANT EXECUTE ON [OTR_Restaurant_UpdateInfo1] TO ExecuteOnlyRole

GO