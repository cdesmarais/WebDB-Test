if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateAssumedSeated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateAssumedSeated]
GO

CREATE Procedure dbo.JobUpdateAssumedSeated

AS
SET NOCOUNT ON

declare @mydate as datetime, @upper as int, @lower as int, @batchSize as int
set @mydate = getdate()
set @batchSize =100

create table #tempReso (Tempid  int IDENTITY(1,1) PRIMARY KEY CLUSTERED, ResID int, AssumedNoShow int)

SET TRANSACTION ISOLATION LEVEL Read uncommitted 

--Insert all the ResID into a temp table
--No reason to look for pending reso older then 67 days 
--We assume all resos older than 67 days will not be pending
insert into #tempReso (resID, AssumedNoShow)
select		ResID,
			max(case when IsNull(callF.SuspectedFraudulentAccountsID,custF.SuspectedFraudulentAccountsID) is not null then 1 else 0 end) AssumedNoShow
from		Reservation r
inner join	Restaurant rest
on			r.RID = rest.RID
INNER JOIN	TimezoneVW tz 
ON			tz.TZID = rest.TZID
left join	SuspectedFraudulentAccounts callF
on			callF.CallerID = r.CallerID 
and			callF.FraudStatusID = 2 /* Assumed NoShow */
left join	SuspectedFraudulentAccounts custF
on			custF.CustID = r.CustID 
and			custF.FraudStatusID = 2 /* Assumed NoShow */
where	shiftdate >= @mydate - 67
and		(
		(shiftdate <= @mydate - 7 and rest.RestaurantType != 'A')
		or		
		(DATEDIFF(hour, (r.ShiftDate + r.ResTime + 2), tz.CurrentLocalTime) >= 48  -- Use More Precision for Allotment Restaurants; Do calculations in Restaurant Local Time
		and rest.RestaurantType = 'A'
		)
)
and		RStateID = 1
group by	ResID

select @upper = max(Tempid) from #tempReso
select @lower = min(Tempid) from #tempReso

while (@upper>=@lower) 
Begin
	--*****************************************************
	--Update all assume seated reso that are older than 7 days and Pending to Assumed Seated
	--Disregard resos that are older than 67 days (they should be in a final state)
	--
	--Perform updates in batches 
	--*****************************************************
	begin transaction
	
		-- Update all pending reso that were identified as Assumed Seated
		update		Reservation
		set			RStateID = 5 /*Assumed Seated*/ 
		where		shiftdate between @mydate - 67 and @mydate  -- Use partition
		and			RstateID = 1 -- verfiy reso state is still pending 
		and			exists (select 		tr.resid
							from		#tempReso TR
							where		Reservation.ResID = TR.ResID
							and			TR.TempID between	@lower and @lower + @batchSize
							and			TR.AssumedNoShow = 0)



		/* Log the Assumed No Shows (follow same rules as the update */
		insert into ResoERBAssumedNoShow (ResID)
		select		r.ResID
		from		Reservation r
		inner join	#tempReso TR
		on			r.ResID = TR.ResID
		and			TR.TempID between	@lower and @lower + @batchSize
		left join	ResoERBAssumedNoShow rns
		on			r.resID = rns.resID
		where		shiftdate between @mydate - 67 and @mydate  -- Use partition
		and			RstateID = 1 -- verfiy reso state is still pending 
					-- Assumed No Show Logic
		and			TR.AssumedNoShow = 1
		and			rns.resID is null /* Don't allow duplicates */


		-- Update all pending reso that were identified as Assumed No Show
		update		Reservation
		set			RStateID = 4 /* No Show */
		where		shiftdate between @mydate - 67 and @mydate  -- Use partition
		and			RstateID = 1 -- verfiy reso state is still pending 
		and			exists (select 		tr.resid
							from		#tempReso TR
							where		Reservation.ResID = TR.ResID
							and			TR.TempID between	@lower and @lower + @batchSize
							and			TR.AssumedNoShow = 1)


	
	commit transaction

	set @lower = @lower + @batchSize
End

GO


GRANT EXECUTE ON [JobUpdateAssumedSeated] TO ExecuteOnlyRole

GO
