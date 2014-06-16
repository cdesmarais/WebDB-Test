if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservations_UpdateStatusFromERB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservations_UpdateStatusFromERB]
GO






CREATE PROCEDURE dbo.Reservations_UpdateStatusFromERB
(@RestaurantID int
,@Cancelled nvarchar(999)
,@NoShow nvarchar(999)
,@Seated nvarchar(999),
@SeatedSize nvarchar(999) = '0',
@ErbResTime nvarchar(999) = '0'
)

AS
--**********************************
--** TODO: EV: Review this proc; it doesn't look like it works. Mixed use of @Seated; sometimes a list of confnumbers, sometimes a single confnumber
--**********************************

/*revised 4-10-2003 by jsd to prevent seated time/reservation time updates with bad (e.g. year = 1970)datetime values from New Listeners
working with bad data from Delphi Listeners*/
/*created 7/2/02 ...
This sproc will update Reservation statuses based on update information sent from the ERBs*/
set nocount on
set transaction isolation level read uncommitted

/*???DO WE NEED SOME VALIDATION HERE TO PREVENT UNAUTHORIZED UPDATES???*/

/*RStateID Name                 Code State
-------------------- -------------------- ---- -----------
1                    Pending              NULL 1
2                    Seated               NULL 2
3                    Cancelled            NULL 3
4                    No-show              NULL 4
5                    Assumed Seated       NULL 5
6                    Disputed             NULL 6
7                    Resolved Dispute     NULL 7
*/
if (len(@Cancelled) > 0)
	Update Reservation set RStateID = 3 /*Cancelled RStateID*/
	where RID = @RestaurantID
	and CHARINDEX(',' + cast(ConfNumber as varchar(10)) + ',',',' + @Cancelled + ',') > 0
if (len(@NoShow) > 0)
	Update Reservation set RStateID = 4 /*No-show RStateID*/
	where RID = @RestaurantID
	and CHARINDEX(',' + cast(ConfNumber as varchar(10)) + ',',',' + @NoShow + ',') > 0
if (len(@Seated) > 0)
	if len(@ErbResTime) = 0
	BEGIN
		--Standard method
		Update Reservation set RStateID = 2 /*Seated RStateID*/
		where RID = @RestaurantID
		and CHARINDEX(',' + cast(ConfNumber as varchar(10)) + ',',',' + @Seated + ',') > 0
	END
	else
	BEGIN
		--Individually Seated with Seated Time

		--Get Reservation Data
		declare @orig_datetime datetime,@PartySize int,@OrigSeatedSize int,@origIncentive int
		declare @oldPoints int,@Incentive int,@newResTime datetime,@ResoPromoID int,@points int
		declare @ResID int
		select @orig_datetime = (ShiftDate + 2 + ResTime),@PartySize = PartySize
			,@OrigSeatedSize = SeatedSize,@origIncentive = incentiveid
			,@oldPoints = ResPoints,@ResoPromoID = coalesce(PromoID,0)
			,@ResID = Reservation.ResID
		 from Reservation
		 left outer join PromoReservations on Reservation.ResID = PromoReservations.ResID
		 where ConfNumber = @Seated and RID = @RestaurantID

		--check to see if the ResTime has changed ...
		if ((@ErbResTime <> @orig_datetime) and (Cast(@ErbResTime as datetime) > '1-1-2002'))/*THE RESO TIME HAS CHANGED*/
		/*The time/date has changed so calculate new Incentive and points values using new date/time...*/
		BEGIN
			set @newResTime = cast(@ErbResTime as datetime) /*Important! must cast as date for comparisons to work!*/
			--select @RestaurantID = RID from Reservation where ResID = @ResID

			--Check for Incented Time Promo
			Declare @IncentedPromo int
			Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where PromoID = @ResoPromoID

			--** Track the change (must occur before actual change)
			--exec ReservationTrackChange @ResID, @ErbResTime, @SeatedSize

			if @IncentedPromo = 1
			BEGIN
				exec procIncentiveLookup @RestaurantID, @newResTime, @incentive OUTPUT
			END
			else
			BEGIN
				Set @Incentive = null
			END

			Exec  Points_Calculate @ResoPromoID,@ErbResTime,@RestaurantID,@PartySize,@Seated,@points OUTPUT

			declare @tempResTime datetime,@tempShiftDate as datetime
			set @tempResTime = cast(@ErbResTime as datetime)
			select  @tempResTime = cast(convert(nvarchar,@tempResTime,108) as datetime) - 2
			set @tempShiftDate = cast( @ErbResTime as datetime)
			set @tempShiftDate = cast(convert(nvarchar,@tempShiftDate,110) as datetime)
			update Reservation
				set
				   RStateID = 2
				,ResTime = @tempResTime
				,ShiftDate = @tempShiftDate
				,incentiveid = @Incentive
				,SeatedSize = @SeatedSize
				,ResPoints = @Points
			where ConfNumber = @Seated and RID = @RestaurantID
		END
		else	/*Reservation Time is the same as Seated Time*/
		BEGIN
			update Reservation
				 set
				 RStateID = 2,SeatedSize = @SeatedSize
			where ConfNumber = @Seated and RID = @RestaurantID
   		END
	END

GO

GRANT EXECUTE ON [Reservations_UpdateStatusFromERB] TO ExecuteOnlyRole

GO
