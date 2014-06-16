if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdatePrivateDiningData_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdatePrivateDiningData_v2]
GO

CREATE PROCEDURE dbo.UpdatePrivateDiningData_v2
(
	@RID int,
	@PrivatePartyContact NVARCHAR(50),
	@PrivateDiningShortDesc NVARCHAR(999),
	@PrivateDiningLongDesc NVARCHAR(999),
	@PrivateDiningMenu NVARCHAR(500),
	@PrivatePartyContactEmail NVARCHAR(510),
	@PrivatePartyPhone NVARCHAR(50),
	@TrackedPhone NVARCHAR(50),  
	@LargestCapacity int,
	@EnablePrivateDining bit,
	@PublishPrivateDining bit,
	@PDThumbNail NVARCHAR(50),
	@HasPrivateParty bit,
	@HasBanquet bit
)

AS

declare @Action as nvarchar(3000)    
declare @DBError int   
declare @LanguageID int  
declare @CallProviderID int 


set @Action = 'Proc Started'    
--***************************    
--** Retrieve LanguageID    
--***************************    
set @Action = 'Retrieve LanguageID'    
exec @LanguageID = procGetDBUserLanguageID    
set @DBError = @@error    

  

UPDATE  dbo.[RestaurantLocal]  
set
  [PrivatePartyContact] = @PrivatePartyContact  
WHERE  rid  = @RID  
AND [LanguageID] = @LanguageID  

update dbo.Restaurant 
set LargestCapacity = @LargestCapacity,
	PrivateDiningMenu = @PrivateDiningMenu,
	PrivatePartyEmail = @PrivatePartyContactEmail,
	PrivatePartyPhone = @PrivatePartyPhone,
	EnablePrivateDining = @EnablePrivateDining,
	publishprivatedining = @PublishPrivateDining,	
	HasPrivateParty = @HasPrivateParty,
	HasBanquet = @HasBanquet
where rid = @RID

SELECT @CallProviderID=CallProviderID FROM dbo.CallProvider WHERE Active= 1
IF  @CallProviderID IS NOT NULL
BEGIN
	IF @TrackedPhone IS NOT NULL
	BEGIN
		IF @TrackedPhone = ''
		BEGIN
			DELETE FROM dbo.CallProviderPrivateDiningNumber 
			WHERE RID=@RID  AND CallProviderID=@CallProviderID		
		END
		ELSE
		IF EXISTS (SELECT 1 FROM dbo.CallProviderPrivateDiningNumber WHERE RID=@RID  AND CallProviderID=@CallProviderID)
		BEGIN
			UPDATE dbo.CallProviderPrivateDiningNumber
				SET PhoneNumber = @TrackedPhone,
					UpdateDtUTC = getutcdate()
			WHERE 
				RID=@RID  AND CallProviderID=@CallProviderID  AND PhoneNumber <> @TrackedPhone
		END 
		ELSE	
		BEGIN
			INSERT INTO dbo.CallProviderPrivateDiningNumber (
				RID
				,CallProviderID
				,PhoneNumber
			)
			VALUES (
				@RID
				,@CallProviderID
				,@TrackedPhone
			)	
		END
	END  
END

if exists (select rid from restaurantimage where rid = @RID) 
BEGIN
	Update dbo.RestaurantImage
		set PrivateDiningThumbnail = @PDThumbNail
	where rid = @RID
END
else
BEGIN
	insert into dbo.RestaurantImage (RID,ShowImage,PrivateDiningThumbnail)
		VALUES (@RID,0,@PDThumbNail)
END

exec dbo.DNRestaurantSetCustomMessageFromName @RID,'PrivatePartyDescription',@PrivateDiningShortDesc 

exec dbo.DNRestaurantSetCustomMessageFromName @RID,'PrivatePartyLongDecription',@PrivateDiningLongDesc  

GO

GRANT EXECUTE ON [UpdatePrivateDiningData_v2] TO ExecuteOnlyRole
GO
