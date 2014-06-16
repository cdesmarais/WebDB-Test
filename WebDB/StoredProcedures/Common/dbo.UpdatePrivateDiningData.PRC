if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdatePrivateDiningData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdatePrivateDiningData]
GO

CREATE PROCEDURE dbo.UpdatePrivateDiningData
(
	@RID int,
	@PrivatePartyContact NVARCHAR(50),
	@PrivateDiningShortDesc NVARCHAR(999),
	@PrivateDiningLongDesc NVARCHAR(999),
	@PrivateDiningMenu NVARCHAR(500),
	@PrivatePartyContactEmail NVARCHAR(510),
	@PrivatePartyPhone NVARCHAR(50),
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


set @Action = 'Proc Started'    
--***************************    
--** Retrieve LanguageID    
--***************************    
set @Action = 'Retrieve LanguageID'    
exec @LanguageID = procGetDBUserLanguageID    
set @DBError = @@error    

  

UPDATE  [RestaurantLocal]  
set
  [PrivatePartyContact] = @PrivatePartyContact  
WHERE  rid  = @RID  
AND [LanguageID] = @LanguageID  

update Restaurant 
set LargestCapacity = @LargestCapacity,
	PrivateDiningMenu = @PrivateDiningMenu,
	PrivatePartyEmail = @PrivatePartyContactEmail,
	PrivatePartyPhone = @PrivatePartyPhone,
	EnablePrivateDining = @EnablePrivateDining,
	publishprivatedining = @PublishPrivateDining,	
	HasPrivateParty = @HasPrivateParty,
	HasBanquet = @HasBanquet
where rid = @RID

if exists (select rid from restaurantimage where rid = @RID) 
BEGIN
Update RestaurantImage
set PrivateDiningThumbnail = @PDThumbNail
where rid = @RID
END
else
BEGIN
insert into RestaurantImage (RID,ShowImage,PrivateDiningThumbnail)
VALUES (@RID,0,@PDThumbNail)
END

exec DNRestaurantSetCustomMessageFromName @RID,'PrivatePartyDescription',@PrivateDiningShortDesc 

exec DNRestaurantSetCustomMessageFromName @RID,'PrivatePartyLongDecription',@PrivateDiningLongDesc  



GO

GRANT EXECUTE ON [UpdatePrivateDiningData] TO ExecuteOnlyRole

GO
