if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DN3GetNoShowInfoFromResID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DN3GetNoShowInfoFromResID]
go


create procedure dbo.DN3GetNoShowInfoFromResID
(
	@ReservationID int
)
as
set nocount on
set transaction isolation level read uncommitted

declare @UserID int
declare @CallerID int

select	top 1	
			@UserID = CustID, 
			@CallerID = coalesce(CallerID,0) 
from		Reservation r 
where		ResID = @ReservationID

declare @NoShowCount int
declare @SeatedCount int
declare @AssumedSeatedCount int
declare @SeatedDisputedCount int
declare @PendingCount int
declare @DisputedCount int
declare @CancelledDisputedCount int
declare @NoShowExcusedCount int
declare @dPastYearDate datetime

set @dPastYearDate = (getdate() - 365)

if (@CallerID = 0)
begin

    select		@NoShowCount = sum(case when RStateID = 4 then 1 else 0 end),
				@SeatedCount = sum(case when RStateID = 2 then 1 else 0 end),
				@AssumedSeatedCount = sum(case when RStateID = 5 then 1 else 0 end),
				@PendingCount = sum(case when RStateID = 1 then 1 else 0 end),
				@DisputedCount = sum(case when RStateID =6 then 1 else 0 end),
				@SeatedDisputedCount = sum(case when RStateID = 7 then 1 else 0 end),
				@CancelledDisputedCount = sum(case when RStateID = 9 then 1 else 0 end),
				@NoShowExcusedCount = sum(case when RStateID = 10 then 1 else 0 end)
    from		Reservation r 
	where		CustID = @UserID 
	and			ShiftDate > @dPastYearDate
	
	select		r.ConfNumber as Confirmation, 
				r.ShiftDate + 2 + r.ResTime as ResDateTime, 
				case when(Coalesce(seatedSize,0) < 1) Then r.Partysize Else seatedSize End as PartySize, 
				r.CustID as UserID,
				0 as CallerID,
				c.FName as FirstName, 
				c.LName as LastName, 
				c.EMail as EMail,
				rest.RName as RestaurantName,
				rest.RID as RestaurantID,
				r.ResID as Reservation_ID,
				r.LanguageID,
				rest.DomainID,
				RStateID as Reservation_State_ID,
				isnull(@NoShowCount,0) as NoShowCount,
				isnull(@SeatedCount,0) as SeatedCount,
				isnull(@AssumedSeatedCount,0) as AssumedSeatedCount,
				isnull(@PendingCount,0) as PendingCount,
				isnull(@DisputedCount,0) as DisputedCount,
				isnull(@SeatedDisputedCount,0) as SeatedDisputedCount,
				isnull(@CancelledDisputedCount,0) as CancelledDisputedCount,
				isnull(@NoShowExcusedCount,0) as NoShowExcusedCount,
				c.ConsumerType as ConsumerType,
				0 as IsConcierge, ResPoints as Points, '' as CallerName,
				isnull(sfa.FraudStatusID, 1) as FraudStatusID			-- Default to 1 = Active
	from		Reservation r 
	inner join	Customer c
	on			r.CustID = c.CustID
	inner join	RestaurantAVW rest 
	on			r.RID = rest.RID 
	and			rest.LanguageID = r.LanguageID
	left join	dbo.SuspectedFraudulentAccounts sfa
	on			sfa.CustID = c.CustID
	where		r.ResID = @ReservationID 
	
end
else
begin

    select		@NoShowCount = sum(case when RStateID = 4 then 1 else 0 end),
				@SeatedCount = sum(case when RStateID = 2 then 1 else 0 end),
				@AssumedSeatedCount = sum(case when RStateID = 5 then 1 else 0 end),
				@PendingCount = sum(case when RStateID = 1 then 1 else 0 end),
				@DisputedCount = sum(case when RStateID =6 then 1 else 0 end),
				@SeatedDisputedCount = sum(case when RStateID = 7 then 1 else 0 end),
				@CancelledDisputedCount = sum(case when RStateID = 9 then 1 else 0 end),
				@NoShowExcusedCount = sum(case when RStateID = 10 then 1 else 0 end)
    from		Reservation r 
	where		CallerID = @CallerID
	and			ShiftDate > @dPastYearDate
	
	select		r.ConfNumber as Confirmation, 
				r.ShiftDate + 2 + r.ResTime as ResDateTime, 
				case when(Coalesce(seatedSize,0) < 1) Then r.Partysize Else seatedSize End as PartySize, 
				r.CustID as UserID,
				r.CallerID as CallerID,
				c.FName as FirstName, 
				c.LName as LastName, 
				c.EMail as EMail,
				rest.RName as RestaurantName,
				rest.RID as RestaurantID,
				r.ResID as Reservation_ID,
				r.LanguageID,
				rest.DomainID,
				RStateID as Reservation_State_ID,
				isnull(@NoShowCount,0) as NoShowCount,
				isnull(@SeatedCount,0) as SeatedCount,
				isnull(@AssumedSeatedCount,0) as AssumedSeatedCount,
				isnull(@PendingCount,0) as PendingCount,
				isnull(@DisputedCount,0) as DisputedCount,
				isnull(@SeatedDisputedCount,0) as SeatedDisputedCount,
				isnull(@CancelledDisputedCount,0) as CancelledDisputedCount,
				isnull(@NoShowExcusedCount,0) as NoShowExcusedCount,
				c.ConsumerType as ConsumerType,
				(case when(c.PositionID = 2) then 1 else 0 end) as IsConcierge, 
				ResPoints as Points, 
				c.FName + ' ' + c.LName as CallerName,
				isnull(sfa.FraudStatusID, 1) as FraudStatusID			-- Default to 1 = Active
	from		Reservation r 
	inner join	Caller c
	on			r.CallerID = c.CallerID 
	inner join	RestaurantAVW rest 
	on			r.RID = rest.RID 
	and			rest.LanguageID = r.LanguageID
	left join	dbo.SuspectedFraudulentAccounts sfa
	on			sfa.CallerID = c.CallerID
	where		r.ResID = @ReservationID
end

go

grant execute on [DN3GetNoShowInfoFromResID] TO ExecuteOnlyRole

go
