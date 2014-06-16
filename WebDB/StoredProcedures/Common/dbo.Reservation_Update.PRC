if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_Update]
GO


CREATE  PROCEDURE dbo.Reservation_Update
(@ReservationID int,
@ReservationStatus int,
@SeatedSize int,
@ErbResTime nvarchar(255) = '0',
@retVal int OUTPUT
)

AS
 
SET NOCOUNT ON
set @retVal = 0
--***************************************
--** If we are about set state to AssumedSeated exit
--** Only the JobUpdateAssumedSeated is allowed to set assuemd seated state
--***************************************
if (@ReservationStatus = 5)
	return

declare @status int
       ,@oldSeated int
       ,@origPartySize int
       ,@Incentive int
       ,@Points int
       ,@RestaurantID int
       ,@ResoIncentiveID int
       ,@ResoPromoID int
       ,@newResTime datetime
       ,@PartnerID int
       ,@RID int
       ,@isErrErb int

select 	
     @status = RStateID
	,@origPartySize = PartySize
	,@oldSeated = SeatedSize
	,@PartnerID = PartnerID
	,@ResoIncentiveID = incentiveid 
	,@ResoPromoID = PromoID
	,@RID = RID
from Reservation
left outer join PromoReservations 
on Reservation.ResID = PromoReservations.ResID
where Reservation.ResID = @ReservationID

--***************************************
--** Identify ERBs that incorrectly process 'result' request
--** 4.6.0, 4.6.1, 4.6.2
--***************************************
select @isErrErb = count(*) from erbrestaurant
	where rid = @RID 
	and listenerVersion like '4.6.[0-2]%'


--***************************************
--** Force seated state to be AssumedSeated 
--** if Reso for an erroneous erb and currently attempting to cancel
--***************************************
if (@isErrErb > 0) and (@ReservationStatus in (3, 8))
begin
	set @ReservationStatus = 5
	set @SeatedSize = @origPartySize
	set @ErbResTime = '0'
end

--***************************************
--** If we are about set state to AssumedSeated exit
--** Only the JobUpdateAssumedSeated is allowed to set assuemd seated state
--***************************************
if (@ReservationStatus = 5)
	return
	

if @ReservationStatus in (3,4,8) /* IF CANCELLATION OR NO-SHOW ONLY ADJUST STATUS ...*/
BEGIN
	BEGIN
		--*** Update the reservation status, if it's current status is not Cancled Web, or Cancled Erb
		update Reservation set RStateID = @ReservationStatus
		where ResID = @ReservationID
				and RStateID not in (3,8)
	END
END
else
BEGIN
	/* Calculate new points for reso */
	declare    @orig_datetime datetime
		,@PartySize int
		,@OrigSeatedSize int
		,@origIncentive int
		,@oldPoints int
	select 	  @orig_datetime = (ShiftDate + 2 + ResTime)
		,@PartySize = PartySize
		,@OrigSeatedSize = SeatedSize
		,@origIncentive = incentiveid
		,@oldPoints = ResPoints
	 from Reservation
	 where ResID = @ReservationID


	if ((@ErbResTime <> '0') and (Cast(@ErbResTime as datetime) > '1-1-2002')) /* If WE GOT A VALID TIME FROM ERB */
	BEGIN
		--check to see if the ResTime has changed ...
		if (@ErbResTime <> @orig_datetime) /*THE RESO TIME HAS CHANGED*/
		/*The time/date has changed so calculate new Incentive and points values using new date/time...*/
		BEGIN
		
			--** Track the change (must occur before actual change)
			exec ReservationTrackChange @ReservationID, @ErbResTime, @SeatedSize
			
			set @newResTime = cast(@ErbResTime as datetime) /*Important! must cast as date for comparisons to work!*/
			select @RestaurantID = RID from Reservation where ResID = @ReservationID

			--Check for Incented Time Promo
			Declare @IncentedPromo int
			Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where PromoID = @ResoPromoID

			if @IncentedPromo = 1 -- Get Incetive ID
			BEGIN
				exec procIncentiveLookup @RestaurantID, @newResTime, @incentive OUTPUT
			END
			else
			BEGIN
				Set @Incentive = null
			END

			-- Standard Calculate number of points
			Exec  Points_Calculate @ResoPromoID,@ErbResTime,@RestaurantID,@PartySize,@ReservationID,@points OUTPUT

			declare @tempResTime datetime,@tempShiftDate as datetime
			set @tempResTime = cast(@ErbResTime as datetime)
			select  @tempResTime = cast(convert(nvarchar,@tempResTime,108) as datetime) - 2
			set @tempShiftDate = cast( @ErbResTime as datetime)
			set @tempShiftDate = cast(convert(nvarchar,@tempShiftDate,110) as datetime)
			update Reservation
				set
				   RStateID = @ReservationStatus
				,SeatedSize = @SeatedSize
				,ResTime = @tempResTime
				,ShiftDate = @tempShiftDate
				,incentiveid = @Incentive
				,ResPoints = @Points
			where ResID = @ReservationID
		END
		else
		BEGIN
			update Reservation
				 set
				 RStateID = @ReservationStatus
				,SeatedSize = @SeatedSize
			where ResID = @ReservationID
		END
	END
	else	/*No Seated Time returned*/
	BEGIN
		update Reservation
			 set
			 RStateID = @ReservationStatus
			,SeatedSize = @SeatedSize
		where ResID = @ReservationID
	END
END
if (@status = 1) --the reso was pending...
	set @retVal = 1

GO

GRANT EXECUTE ON [Reservation_Update] TO ExecuteOnlyRole

GO
