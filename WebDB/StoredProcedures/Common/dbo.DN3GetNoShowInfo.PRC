if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DN3GetNoShowInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DN3GetNoShowInfo]
GO


CREATE PROCEDURE dbo.DN3GetNoShowInfo
 (
  @RestaurantID int,
  @ConfirmationID nvarchar(20)
 )
As
--******************************
--** Retrieves Reso info in the language of the Reso
--******************************

set nocount on
set transaction isolation level read uncommitted

declare @UserID int
declare @CallerID int
declare @ResID int

-- Take the most recent match
-- NOTE: This logic is a complement of DNBRUPReservationUpdateStatus
Select		top 1
			@ResID = resID, 
			@UserID = CustID, 
			@CallerID = coalesce(CallerID,0) 
from		Reservation r 
where		RID = @RestaurantID
and			ConfNumber = @ConfirmationID 
and			RStateID <> 3
order by	resid desc


declare @NoShowCount int
declare @SeatedCount int
declare @PendingCount int

declare @dPastYearDate datetime
set @dPastYearDate = (getdate() - 365)
if @CallerID = 0
begin
	    select	@NoShowCount = sum(case when RStateID = 4 then 1 else 0 end),
				@SeatedCount = sum(case when RStateID in (2,5,7) then 1 else 0 end),
				@PendingCount = sum(case when RStateID = 1 then 1 else 0 end)
	    from	Reservation r 
		where	CustID = @UserID 
		and		ShiftDate > @dPastYearDate
		 

	SELECT  
		rest.DomainID,
		r.LanguageID,
		r.ConfNumber AS Confirmation, 
	    r.ShiftDate + 2 + r.ResTime AS ResDateTime, 
	    r.PartySize AS PartySize, 
	    r.CustID AS UserID,
	    0 As CallerID,
	    Customer.FName AS FirstName, 
	    Customer.LName AS LastName, 
	    Customer.EMail as EMail,
	    rest.RName AS RestaurantName,
	    rest.RID AS RestaurantID,
	    ResID as Reservation_ID,
	    RStateID as Reservation_State_ID,
	    @NoShowCount as NoShowCount,
	    @SeatedCount as SeatedCount,
	    @PendingCount as PendingCount,
	    Customer.ConsumerType as ConsumerType,
    	    0 as IsConcierge,
    	    coalesce(Customer.SFName,'') as SortableFirstName,
    	    coalesce(Customer.SLName,'') as SortableLastName
	from Reservation r 
	inner JOIN Customer 
	ON        r.CustID = Customer.CustID
	INNER JOIN RestaurantAVW rest
	ON			r.RID = rest.RID 
	and			rest.LanguageID = r.LanguageID
	WHERE		r.resid = @ResID 
end
else
begin

	    select	@NoShowCount = sum(case when RStateID = 4 then 1 else 0 end),
				@SeatedCount = sum(case when RStateID in (2,5,7) then 1 else 0 end),
				@PendingCount = sum(case when RStateID = 1 then 1 else 0 end)
	    from	Reservation r 
		where	CallerID = @CallerID 
		and		ShiftDate > @dPastYearDate
		
	SELECT 
		rest.DomainID,
		r.LanguageID,	
		r.ConfNumber AS Confirmation, 
	    r.ShiftDate + 2 + r.ResTime AS ResDateTime, 
	    r.PartySize AS PartySize, 
	    r.CustID AS UserID,
	    r.CallerID As CallerID,
	    Caller.FName AS FirstName, 
	    Caller.LName AS LastName, 
	    Caller.EMail as EMail,
	    rest.RName AS RestaurantName,
	    rest.RID AS RestaurantID,
	    ResID as Reservation_ID,
	    RStateID as Reservation_State_ID,
	    @NoShowCount as NoShowCount,
	    @SeatedCount as SeatedCount,
	    @PendingCount as PendingCount,
	    Caller.ConsumerType as ConsumerType,
	    (case when(Caller.PositionID = 2) then 1 else 0 end) as IsConcierge,
	    coalesce(Caller.SFName,'') as SortableFirstName,
    	    coalesce(Caller.SLName,'') as SortableLastName
	from Reservation r 
	INNER JOIN Caller 
	ON         r.CallerID = Caller.CallerID 
	INNER JOIN RestaurantAVW rest
	ON			r.RID = rest.RID 
	and			r.LanguageID = rest.LanguageID
	WHERE		r.resid = @ResID 
end

GO

GRANT EXECUTE ON [DN3GetNoShowInfo] TO ExecuteOnlyRole

GO
