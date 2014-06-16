if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_UpdateForChange_WithCC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_UpdateForChange_WithCC]
GO


CREATE PROCEDURE dbo.Reservation_UpdateForChange_WithCC
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
, @CCNumber nvarchar(4)
,@retVal nvarchar(255) OUTPUT
)

 AS
SET NOCOUNT ON
--*******************************************
--** Proc Tuned for Reservation Partitioning
--** Only allow updates to data in past 30 days
--*******************************************
Declare @incentiveID int
Select	top 1
		@incentiveID = coalesce(incentiveid,0) 
from	Reservation 
where	ResID = @ReservationID 
and		shiftdate > getdate() - 30
if @@rowcount = 0 
begin
	Return(0) --send back null Reservation id to indicate a problem occurred...
end


if @incentiveID > 0
BEGIN
	exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentiveID OUTPUT

	if @incentiveID is null and exists (select resid from PromoReservations where resid = @ReservationID)
	BEGIN
		Delete from PromoReservations where resid = @ReservationID
	END

END
else
BEGIN

	if exists (select ResID from PromoReservations
		inner join Promos on PromoReservations.PromoID = Promos.PromoID
		where ResID = @ReservationID and DiningIncentive = 1)
	BEGIN
		exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentiveID OUTPUT

		if @incentiveID is null and exists (select resid from PromoReservations where resid = @ReservationID)
		BEGIN
			Delete from PromoReservations where resid = @ReservationID
		END

	END
	else
	BEGIN
		Set @incentiveID = null
	END

END



/*Update Reservation ...*/

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
where	ResID = @ReservationID
and		shiftdate > getdate() - 30

if @CCNumber <> ''
BEGIN
	update reservation set CreditCardLastFour = @CCNumber where ResID = @ReservationID
END


if @@ERROR <> 0
	Return(0) --send back null Reservation id to indicate a problem occurred...

--SET IDENTITY and RETVAL--
/*        
	if @incentiveID is not null
		BEGIN
			SET @retval = 'i' + cast(@ResID as nvarchar(255))
		END
	else
*/
		set @retval = @ReservationID
GO

GRANT EXECUTE ON [Reservation_UpdateForChange_WithCC] TO ExecuteOnlyRole

GO
