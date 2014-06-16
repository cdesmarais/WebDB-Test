if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ErbSeated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ErbSeated]
GO


CREATE  procedure dbo.Reservation_ErbSeated

  @RestaurantID			int
,@ConfirmationID		nvarchar(20)
,@SeatedSize			int
,@SeatedTime			datetime

as


--Get Reservation Data
--Select Top 1 has been used to improve performance of the Partitioned Reservation Table
--It should only pull one record as RID and ConfNumber combination is unique in the table
--********************************************************************
declare	  @ResID		int
		,@origResDateTime		datetime
		,@partySize			int

select		top 1 
			@ResID = Reservation.ResID
			,@origResDateTime = (ShiftDate + 2 + ResTime)
			,@partySize = PartySize
from		Reservation
where		RID = @RestaurantID
and			ConfNumber = @ConfirmationID
AND			ShiftDate >= DATEADD(d,-30, GETDATE())
--********************************************************************

-- Per the Business Rule Resos older than 30 days are not allowed to be updated
if (@ResID is null)
 return

--************
--** Check if restaurant is a 4.6 or above erb
--************
declare @isNewErb int
select	@isNewErb = count(*) 
from	erbrestaurant
where	rid = @RestaurantID 
and		(listenerVersion like '4.[6-9]%' or listenerVersion like '[5-9].%')

--*********************************
--** If the ERB is not a new ERb (4.6 or greater)
--** and the time has changed
--** Then recalculate the reservation points
--** and update the reservation time
--*********************************
if (@origResDateTime <> @SeatedTime) and (@isNewErb = 0)
begin
	declare   @incentiveID	int
			,@points		int

	--Get Incentive ID and Points
	exec dbo.Reservation_GetPointsIncentive @SeatedTime, @ResID, @points OUTPUT, @incentiveID output

	if @IncentiveID = 0
	BEGIN
		Set @IncentiveID = null
	END

	--Update!!
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	declare   @xResTime			datetime
			,@xShiftDate		datetime

	set @xResTime = cast(convert(nvarchar,@SeatedTime,108) as datetime) - 2
	set @xShiftDate = cast(convert(nvarchar,@SeatedTime,110) as datetime)

--Per the BizRule resos older than 30 are not allowed to be updated
--Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table

	update Reservation
	set RStateID = 2
		--Update Reservation date/time w/datetime from listener
		,ResTime = @xResTime
		,ShiftDate = @xShiftDate
		,incentiveid = @incentiveID
		,SeatedSize = @SeatedSize
		,ResPoints = @points
	where ResID = @ResID
	and ShiftDate >= DATEADD(d,-30, GETDATE())
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

end 

else
begin
--*****************
--** Time didn't change or it is a new erb (4.6 or above)
--** Just update the reso state and seated size
--*****************
	--update state,seated size
	update Reservation
	set	  RStateID = 2
		,SeatedSize = @SeatedSize
	where ResID = @ResID and RstateID != 2
	and ShiftDate >= DATEADD(d,-30, GETDATE())

end

GO

GRANT EXECUTE ON [Reservation_ErbSeated] TO ExecuteOnlyRole

GO
