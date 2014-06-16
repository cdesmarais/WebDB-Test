if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAddRestaurantRoom]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAddRestaurantRoom]
GO

--would prefer to pass a table as a table variable which is supported in SQL 5008
--proc will be updated to do so when support is available
CREATE PROCEDURE dbo.DNAddRestaurantRoom
(
	@RID int,
	
	@RoomName1 nvarchar(100),
	@RoomDesc1 nvarchar(500),
	@SeatedSize1 int,
	@StandingSize1 int,
	@ImageName1 nvarchar(100),
	@ListingOrder1 int,
	@Active1 bit,
	
	@RoomName2 nvarchar(100),
	@RoomDesc2 nvarchar(500),
	@SeatedSize2 int,
	@StandingSize2 int,
	@ImageName2 nvarchar(100),
	@ListingOrder2 int,
	@Active2 bit,
	
	@RoomName3 nvarchar(100),
	@RoomDesc3 nvarchar(500),
	@SeatedSize3 int,
	@StandingSize3 int,
	@ImageName3 nvarchar(100),
	@ListingOrder3 int,
	@Active3 bit,
	
	@RoomName4 nvarchar(100),
	@RoomDesc4 nvarchar(500),
	@SeatedSize4 int,
	@StandingSize4 int,
	@ImageName4 nvarchar(100),
	@ListingOrder4 int,
	@Active4 bit,
	
	@RoomName5 nvarchar(100),
	@RoomDesc5 nvarchar(500),
	@SeatedSize5 int,
	@StandingSize5 int,
	@ImageName5 nvarchar(100),
	@ListingOrder5 int,
	@Active5 bit,
	
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

--update general info first

exec [UpdatePrivateDiningData] @rid,@PrivatePartyContact,@PrivateDiningShortDesc,@PrivateDiningLongDesc,@PrivateDiningMenu,@PrivatePartyContactEmail,@PrivatePartyPhone,@LargestCapacity,@EnablePrivateDining,@PublishPrivateDining,@PDThumbNail,@HasPrivateParty,@HasBanquet

--now update rooms
if exists(select RID from RestaurantRooms where RID = @RID)
BEGIN
	delete RestaurantRooms where RID = @RID
END

insert into RestaurantRooms Values (@RID, @RoomName1, @RoomDesc1, @SeatedSize1, @StandingSize1, @ImageName1, @ListingOrder1, @Active1)
insert into RestaurantRooms Values (@RID, @RoomName2, @RoomDesc2, @SeatedSize2, @StandingSize2, @ImageName2, @ListingOrder2, @Active2)
insert into RestaurantRooms Values (@RID, @RoomName3, @RoomDesc3, @SeatedSize3, @StandingSize3, @ImageName3, @ListingOrder3, @Active3)
insert into RestaurantRooms Values (@RID, @RoomName4, @RoomDesc4, @SeatedSize4, @StandingSize4, @ImageName4, @ListingOrder4, @Active4)
insert into RestaurantRooms Values (@RID, @RoomName5, @RoomDesc5, @SeatedSize5, @StandingSize5, @ImageName5, @ListingOrder5, @Active5)

GO

GRANT EXECUTE ON [DNAddRestaurantRoom] TO ExecuteOnlyRole

GO
