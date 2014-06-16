if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ErbSeatedV2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ErbSeatedV2]
GO


CREATE  procedure dbo.Reservation_ErbSeatedV2

  @RestaurantID			int
 ,@ConfirmationID		nvarchar(20)
 ,@SeatedSize			int
 ,@SeatedTime			datetime
 ,@AssumedSeated		bit = 0

as


--Get Reservation Data
--Select Top 1 has been used to improve performance of the Partitioned Reservation Table
--It should only pull one record as RID and ConfNumber combination is unique in the table
--********************************************************************
declare	  @ResID				int
		 ,@origResDateTime		datetime
		 ,@partySize			int
		 ,@CurrentRStateID		int
		 ,@NextRStateID			int
		 ,@MaxWebPartySize	int
		 ,@CallerID	int
		 ,@CustID	int

set @MaxWebPartySize = 20

select		top 1 
			 @ResID				= Reservation.ResID
			,@origResDateTime	= (ShiftDate + 2 + ResTime)
			,@partySize			= PartySize
			,@CurrentRStateID	= RStateID
			,@CallerID			= CallerID
			,@CustID			= CustID
from		Reservation
where		RID = @RestaurantID
and			ConfNumber = @ConfirmationID
AND			ShiftDate >= DATEADD(d,-30, GETDATE())
--********************************************************************

-- Per the Business Rule Resos older than 30 days are not allowed to be updated
if (@ResID is null)
 return
 
--************
--** Check if User is suspected of Fraud
--************
declare @AssumedNoShow int
set @AssumedNoShow = 0
if (@AssumedSeated = 1)
begin
	if (@CallerID is not null)
	begin
		--Check the Fraud table using the CallerID
		if exists (
			select SuspectedFraudulentAccountsID
			from	SuspectedFraudulentAccounts 
			where	CallerID = @CallerID 
			and		FraudStatusID = 2 /* Assumed NoShow */
			)
		begin
			set @AssumedNoShow = 1			
		end
	end
	else
	begin
		--Check the Fraud table using the CustID
		if exists (
			select SuspectedFraudulentAccountsID
			from	SuspectedFraudulentAccounts 
			where	CustID = @CustID
			and		FraudStatusID = 2 /* Assumed NoShow */
			)
		begin
			set @AssumedNoShow = 1			
		end		
	end
end

--************
--** Calculate the next reservation state (Seated or Assumed Seated)
--************
select @NextRStateID = (case 
						when (@AssumedNoShow = 1) then 4 --**Assumed NoShow
						when (@AssumedSeated = 1) then 5 --**Assumed Seated
						else 2 --**Seated
						end)

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
	set  RStateID = @NextRStateID
		 --Update Reservation date/time w/datetime from listener
		,ResTime = @xResTime
		,ShiftDate = @xShiftDate
		,incentiveid = @incentiveID
		,SeatedSize = case when (0 < @SeatedSize and @SeatedSize <= @MaxWebPartySize) then @SeatedSize else SeatedSize end
		,ResPoints = @points
	where ResID = @ResID
	and ShiftDate >= DATEADD(d,-30, GETDATE())
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

end 
else
begin
--*****************
--** Time didn't change
--** Just update the reso state and seated size
--** provided either Reservation State or Party Size has changed
--*****************
	--update state,seated size
	update Reservation
	set	  RStateID = @NextRStateID
		 ,SeatedSize = case when (0 < @SeatedSize and @SeatedSize <= @MaxWebPartySize) then @SeatedSize else SeatedSize end
	where ResID = @ResID 
	and ShiftDate >= DATEADD(d,-30, GETDATE())
	and	(RstateID != @NextRStateID
		or SeatedSize != (case when (0 < @SeatedSize and @SeatedSize <= @MaxWebPartySize) then @SeatedSize else SeatedSize end)
	)

end

if (	@AssumedNoShow = 1 
    	and (not exists (select ResID from ResoERBAssumedNoShow where ResID = @ResID)))
begin
	insert	ResoERBAssumedNoShow
	(	ResID 	)
	values	
	(	@ResID	)
end
else if (	@AssumedSeated = 1 
    	and (not exists (select ResID from ResoERBAssumedSeated where ResID = @ResID)))
begin
	insert	ResoERBAssumedSeated
	(	ResID 	)
	values	
	(	@ResID	)
end

GO

GRANT EXECUTE ON [Reservation_ErbSeatedV2] TO ExecuteOnlyRole

GO
