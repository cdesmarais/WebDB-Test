
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetPointsIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetPointsIncentive]
GO






CREATE PROCEDURE dbo.Reservation_GetPointsIncentive

@ResDateTime datetime,
@resID int,
@Points int = 0 OUTPUT,
@IncentiveID int = 0 OUTPUT

AS

--**********************************
--** Proc is used to determine if a Reso that is changed by the ERB
--** still qualifies for DIP (incentive) points or not
--**********************************
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare	  	 @origResDateTime		datetime
    		,@partySize			int
	    	,@RestaurantID			int 
    		,@OriginalIncentiveID		int 
		    ,@OriginalPoints	int
		    ,@PartnerID			int 

Declare @IncentedPromo int, @HotelID int, @isblocked int


--*********************************************
--** Retrieve essential Reservation Info
--** Proc is tunned for use with Reso Partition
--*********************************************
select  top 1  
			@RestaurantID = Reservation.RID
			,@origResDateTime = (ShiftDate + 2 + ResTime)
			,@OriginalPoints = ResPoints
			,@OriginalIncentiveID = coalesce(IncentiveID,0)
			,@partySize = PartySize
			,@HotelID = coalesce(CompanyID,0)
			,@PartnerID = PartnerID
from		Reservation
where		Reservation.Resid = @resID
AND			ShiftDate >= DATEADD(d,-30, GETDATE())


Set  @ResDateTime = cast(@ResDateTime as datetime)

--If the reso is incented (DIP / POP) then validiate rules still apply 
if @OriginalIncentiveID != 0
BEGIN
	
	--*** Must honor points; either because incentive is active or because it was previously awarded
	select 	@Points = amount, 
		    @IncentiveID = IncentiveID 
	from 	Incentive 
	where 	IncentiveID = @OriginalIncentiveID
	and     IncentiveDay = datepart(dw,@ResDateTime) 
	and     dbo.fGetDatePart(@ResDateTime) between Startdate and EndDate
	and     StartTime <= dbo.fGetTimePart(@ResDateTime)
	and     EndTime > dbo.fGetTimePart(@ResDateTime) --** End Time is not inclusive
	and     RID=@RestaurantID


	
	if @Points is null
		exec procIncentiveLookup @RestaurantID, @ResDateTime, @IncentiveID OUTPUT, @Points OUTPUT
	
	if @Points is null
	BEGIN
		Set @Points = 100
		Set @IncentiveID = 0
	END
	else
	BEGIN
		if exists(Select HolidayID 
					from HolidaySchedule 
					where HolidayDate = cast(convert(nvarchar, cast(@ResDateTime as datetime), 110) as datetime) 
					and
					SuppressDIP = 1)
		BEGIN
			Set @Points = 100
			Set @IncentiveID = 0
		END
	END
END
ELSE
BEGIN
	-- If it is not an incentive ID (POP / DIP) then preserve the original points
	SET @Points = IsNull(@OriginalPoints, 100) -- if the original points could not be retrieved then set them to 100
	Set @IncentiveID = 0
END
	
GO

GRANT EXECUTE ON [Reservation_GetPointsIncentive] TO ExecuteOnlyRole

GO
