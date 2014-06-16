if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RestaurantMessage_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RestaurantMessage_Add]
GO

CREATE PROCEDURE dbo.Admin_RestaurantMessage_Add
(
    @RestaurantID int,
    @LanguageID int=1,
    @CaterDescription nvarchar(999),
    @RestaurantMessage nvarchar(999),
    @Entertainment nvarchar(999),
    @ParkingDescription nvarchar(999),
    @PrivatePartyDescription nvarchar(999),
    @BanquetDescription nvarchar(999),
    @ConfirmationMessage nvarchar(999),
    @PublicTransit nvarchar(999),
    @Hours nvarchar(999)
)
As

SET NOCOUNT ON

begin tran AddMessages

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'CaterDescription',@CaterDescription
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'RestaurantDescription',@RestaurantMessage
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'Entertainment',@Entertainment
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'ParkingDescription',@ParkingDescription
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'PrivatePartyDescription',@PrivatePartyDescription
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'BanquetDescription',@BanquetDescription
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'PublicTransit',@PublicTransit
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'Hours',@Hours
if @@Error<> 0	goto error
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'Confirmation',@ConfirmationMessage
if @@Error<> 0	goto error


INSERT INTO RestaurantJustAdded (RID,JustAdded)
values (@RestaurantID,'0')

if @@Error<> 0
	goto error

Commit tran AddMessages
Return(0)

error:
rollback tran AddMessages
Return(1)
GO

GRANT EXECUTE ON [Admin_RestaurantMessage_Add] TO ExecuteOnlyRole

GO
