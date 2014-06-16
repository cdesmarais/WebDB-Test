if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationUpdate]
GO




CREATE PROCEDURE dbo.DNReservationUpdate
(@ReservationID int,
@ReservationStatus int,
@SeatedSize int,
@ErbResTime nvarchar(255) = '0',
@retVal int OUTPUT
)
/*revised 4/10/2003 to swallow bad times that were created by old Delphi listeners (with full date-time values in ResTime field...)*/
 AS
--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************


SET NOCOUNT ON
declare @status int,@oldSeated int,@origPartySize int
declare @Incentive int,@Points int,@RestaurantID int
declare @ResoIncentiveID int, @ResoPromoID int
declare @newResTime datetime,@PartnerID int


select 	@status = RStateID
	,@origPartySize = PartySize
	,@oldSeated = SeatedSize
	,@PartnerID = PartnerID, @ResoIncentiveID = incentiveid ,@ResoPromoID = PromoID
from Reservation
left outer join PromoReservations on Reservation.ResID = PromoReservations.ResID
where Reservation.ResID = @ReservationID


set @retVal = 0

if @ReservationStatus in (3,4,8) /* IF CANCELLATION OR NO-SHOW ONLY ADJUST STATUS ...*/
BEGIN
	if (Select RStateID from Reservation where ResID = @ReservationID) <> 3
	BEGIN
		update Reservation set RStateID = @ReservationStatus
		where ResID = @ReservationID
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
			set @newResTime = cast(@ErbResTime as datetime) /*Important! must cast as date for comparisons to work!*/
			select @RestaurantID = RID from Reservation where ResID = @ReservationID

			--Check for Incented Time Promo
			Declare @IncentedPromo int
			Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where PromoID = @ResoPromoID

			--** Track the change (must occur before actual change)
			--exec ReservationTrackChange @ReservationID, @newResTime, @SeatedSize

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



GRANT EXECUTE ON [DNReservationUpdate] TO ExecuteOnlyRole

GO
