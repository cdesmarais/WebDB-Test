if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_UpdateForChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_UpdateForChange]
GO

CREATE PROCEDURE dbo.Reservation_UpdateForChange
(@ReservationID int
,@ResDateTime datetime
,@PartySize int
,@Phone nvarchar(255)
,@Notes nvarchar(999)
,@Confirmation int
,@RestaurantID int
,@Business bit
,@FirstTime bit
,@Points int
,@UseCheque int
,@LargeParty bit
,@retVal nvarchar(255) OUTPUT
)

 AS
SET NOCOUNT ON

Declare @incentiveID int
Select @incentiveID = coalesce(incentiveid,0) from Reservation where ResID = @ReservationID
if @incentiveID > 0
BEGIN
	exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentiveID OUTPUT
END
else
BEGIN

	if exists (select ResID from PromoReservations
		inner join Promos on PromoReservations.PromoID = Promos.PromoID
		where ResID = @ReservationID and DiningIncentive = 1)
	BEGIN
		exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentiveID OUTPUT
	END
	else
	BEGIN
		Set @incentiveID = null
	END

END

update Reservation set 
ShiftDate = cast(convert(nvarchar,@ResDateTime,110) as datetime),
ResTime = cast(convert(nvarchar,@ResDateTime,108) as datetime) - 2,
PartySize = @PartySize,
ConfNumber = @Confirmation,
ContactPhone = @Phone,
Business = @Business,
FirstTime = @FirstTime,
ResPoints = @Points,
UseDiningCheque = @UseCheque,
LargeParty = @LargeParty,
incentiveid = @incentiveID
,notes = @Notes
where
ResID = @ReservationID

if @@ERROR <> 0
	Return(0) --send back null Reservation id to indicate a problem occurred...


		set @retval = @ReservationID
GO

GRANT EXECUTE ON [Reservation_UpdateForChange] TO ExecuteOnlyRole

GO
