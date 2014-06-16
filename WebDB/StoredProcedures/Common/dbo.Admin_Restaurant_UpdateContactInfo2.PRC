
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateContactInfo2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateContactInfo2]
GO


CREATE PROCEDURE [dbo].[Admin_Restaurant_UpdateContactInfo2]
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
	@CateringOptions nvarchar(1998),
	@HasNoFax BIT,
	@TwitterAcctName nvarchar(50),
	@FacebookURL NVARCHAR(250)
)

AS

declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int 
declare @LanguageID int
declare @DomainID int
set @ProcName = 'Admin_Restaurant_UpdateContactInfo2'  
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

if @Longitude = 0 or @Latitude = 0
BEGIN
	Set @Longitude = NULL
	Set @Latitude = NULL

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
		[HasNoFax] = @HasNoFax,
		[TwitterAccountName] = @TwitterAcctName,
		[FacebookURL] = @FacebookURL
WHERE 	[RID] = @RestaurantID


exec DNRestaurantSetCustomMessageFromName @RestaurantID,'ParkingDescription',@ParkingOption

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'PublicTransit',@PublicTransport

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'CaterDescription',@CateringOptions


COMMIT TRANSACTION  
Return(0)  
  
error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1)  
  
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateContactInfo2] TO ExecuteOnlyRole

GO

