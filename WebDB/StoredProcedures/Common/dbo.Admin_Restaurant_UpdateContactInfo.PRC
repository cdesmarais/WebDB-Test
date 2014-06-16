
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateContactInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateContactInfo]
GO


CREATE PROCEDURE [dbo].[Admin_Restaurant_UpdateContactInfo]
 (
	@RestaurantID int,
	@Address1 nvarchar(256),  
	@Address2 nvarchar(256), 
	@City nvarchar(80), 
	@State nvarchar(80), 
	@Zip nvarchar(40), 
	@Country char(2), 
	@MappingAddress nvarchar(256), 
	@Longitude dec(10,6) = 0,
	@Latitude dec(10,6) = 0,
	@MapAddrValid int, 
	@CrossStreet nvarchar(150), 
	@Parking int, 
	@ParkingOption nvarchar(1998), 
	@PublicTransport nvarchar(1998), 
	@WebAddress nvarchar(256), 
	@Email nvarchar(510), 
	@ReservationCode nvarchar(100), 
	@MenuLink nvarchar(500), 
	@Phone varchar(24), 
	@Fax varchar(20), 
	@BanquetContact nvarchar(100), 
	@BanquetPhone varchar(20), 
	@BanquetOptions nvarchar(1998), 
	@CateringOptions nvarchar(1998),
	@HasNoFax bit  
)

AS

declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int 
declare @LanguageID int
declare @HasBanquet int, @DomainID int
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

Select @DomainID = DomainID from Restaurant where RID = @RestaurantID

BEGIN
	UPDATE 	[RestaurantLocal]
		SET 	[Address1] = @Address1,
			[Address2] = @Address2,
			[City] = @City,
			[State] = @State,
			[CrossStreet] = @CrossStreet
	WHERE 	[RID] = @RestaurantID
	AND	[LanguageID] = @LanguageID
	
END


UPDATE 	[RestaurantLocal]
	SET 	[BanquetContact] = @BanquetContact
WHERE 	[RID] = @RestaurantID
AND	[LanguageID] = @LanguageID


if @Longitude = 0 or @Latitude = 0
BEGIN
	Set @Longitude = NULL
	Set @Latitude = NULL

END

Set @HasBanquet = 0


if @BanquetOptions != '' or @BanquetContact != ''
BEGIN
	Set @HasBanquet = 1
END

if right(@BanquetPhone,1) = 'x'
BEGIN
	Set @BanquetPhone = replace(@BanquetPhone,'x','')
END

if right(@Phone,1) = 'x'
BEGIN
	Set @Phone = replace(@Phone,'x','')
END


UPDATE 	[Restaurant]
	SET 	[Zip] = @Zip,
		[Country] = @Country,
		[MappingAddress] = @MappingAddress,
		[Latitude] = @Latitude,
		[Longitude] = @Longitude,
		[MapAddrValid] = @MapAddrValid,
		[ParkingID] = @Parking,
		[ExternalURL] = @WebAddress,
		[Email] = @Email,
		[ReserveCode] = @ReservationCode,
		[MenuURL] = @MenuLink,
		[ReservationPhone] = @Phone,
		[Phone] = @Phone,
		[FaxPhone] = @Fax,
		[BanquetPhone] = @BanquetPhone,
		[HasBanquet] = @HasBanquet,
		[HasNoFax] = @HasNoFax  
WHERE 	[RID] = @RestaurantID


exec DNRestaurantSetCustomMessageFromName @RestaurantID,'ParkingDescription',@ParkingOption

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'PublicTransit',@PublicTransport

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'BanquetDescription',@BanquetOptions

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'CaterDescription',@CateringOptions


COMMIT TRANSACTION  
Return(0)  
  
error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1)  
  
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateContactInfo] TO ExecuteOnlyRole

GO

