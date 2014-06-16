if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RestaurantMessage_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RestaurantMessage_Update]
GO

CREATE Procedure dbo.Admin_RestaurantMessage_Update
(
    @RestaurantID int,
    @LanguageID int,
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
AS

SET NOCOUNT ON

begin tran SetMessages

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

Commit tran SetMessages
Return(0)

error:
rollback tran SetMessages
Return(1)
GO

GRANT EXECUTE ON [Admin_RestaurantMessage_Update] TO ExecuteOnlyRole

GO
