if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ErbChanged]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ErbChanged]
GO


CREATE  procedure dbo.Reservation_ErbChanged
  @RestaurantID			int
,@ConfirmationID		nvarchar(20)
,@SeatedSize			int
,@SeatedTime			datetime
as
--********************************************************************
--** PROC: Reservation_ErbChanged
--** Responsible for handling Reso changes made from erb
--** Code is based on Reservation_ErbSeated
--********************************************************************


--Get Reservation Data
--Select Top 1 has been used to improve performance of the Partitioned Reservation Table
--It should only pull one record as RID and ConfNumber combination is unique in the table
--****************************************************************************************
declare	  @ResID		int
		,@origResDateTime		datetime
		--,@resPromoID			int
		,@partySize			int
			,@MaxWebPartySize	int

set @MaxWebPartySize = 20

select    top 1 @ResID = Reservation.ResID
		,@origResDateTime = (ShiftDate + 2 + ResTime)
		--,@resPromoID = coalesce(PromoID,0)
		,@partySize = PartySize
from      Reservation
--left join PromoReservations 
--on        Reservation.ResID = PromoReservations.ResID
where     RID = @RestaurantID
and       ConfNumber = @ConfirmationID
and			ShiftDate >= dateadd(d,-30, getdate())
--********************************************************************

if (@ResID is null)
BEGIN
	--** Reso is not in our DB; likely a "lost make"
	--** Queue this reso for cancelation
	if not exists (select CancelQueueID from CancelQueue where rid = @RestaurantID and ConfNumber = @ConfirmationID)
	begin
		insert into CancelQueue (RID, ConfNumber, ShiftDT, PartySize)
			values (@RestaurantID, @ConfirmationID, @SeatedTime, @partySize)
	end
	return

END
/*
if (@origResDateTime <> @SeatedTime) or (@SeatedSize <> @partySize)
BEGIN
	--** Track the change (must occur before actual change)
	exec ReservationTrackChange @ResID, @SeatedTime, @SeatedSize
END
*/
--*********************************
--** If the time has changed
--** Then recalculate the reservation points
--** and update the reservation time
--*********************************
if (@origResDateTime <> @SeatedTime)
begin
	declare   @incentiveID	int
			,@points		int


	--Get Incentive ID and Points
	exec dbo.Reservation_GetPointsIncentive @SeatedTime, @ResID, @points OUTPUT, @incentiveID output

	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	--exec Reservation_GetIncentiveID @RestaurantID,@SeatedTime,@resPromoID,@incentiveID output
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	--Get Points
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	--exec Points_Calculate @resPromoID,@SeatedTime,@RestaurantID,@partySize,@ResID,@points OUTPUT
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	if @IncentiveID = 0
	BEGIN
		Set @IncentiveID = null
	END

	--Get New Time
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	declare   @xResTime			datetime
			,@xShiftDate		datetime

	set @xResTime = cast(convert(nvarchar,@SeatedTime,108) as datetime) - 2
	set @xShiftDate = cast(convert(nvarchar,@SeatedTime,110) as datetime)

--Per the BizRule resos older than 30 are not allowed to be updated
--Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table

	update Reservation
	set ResTime = @xResTime
		,ShiftDate = @xShiftDate
		,incentiveid = @incentiveID
		,PartySize = case when (0 < @SeatedSize and @SeatedSize <= @MaxWebPartySize) then @SeatedSize else PartySize end
		,ResPoints = @points
	where ResID = @ResID	
	and ShiftDate >= dateadd(d,-30, getdate())
end 
else
begin

	if (@SeatedSize <> @partySize)
	BEGIN
		update Reservation
		set PartySize = case when (0 < @SeatedSize and @SeatedSize <= @MaxWebPartySize) then @SeatedSize else PartySize end
		where ResID = @ResID
		and ShiftDate >= dateadd(d,-30, getdate())
	END
end


GO

GRANT EXECUTE ON [Reservation_ErbChanged] TO ExecuteOnlyRole

GO
