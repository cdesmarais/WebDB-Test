if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobGroupReportDailyExcelExport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobGroupReportDailyExcelExport]
go

create  Procedure [dbo].[JobGroupReportDailyExcelExport]
(
  @GID int,
  @DateOffset int = 0,
  @NumDaysOffset int = -7
)
AS
	-- this is a group report that breaks down various reso states by day. @DateOffset=0 means starting 12:00am this morning
	-- @NumDaysOffset means the number of days going back from the offset value, ie -7 means that the report will start one week ago and end with mid night this morning
	
	
	set transaction isolation level read uncommitted
	
	declare @startDT datetime
	declare @endDT datetime
	
	select @startDT = cast(convert(char(8), getdate() + (@NumDaysOffSet), 112) as datetime)
	select @endDT = cast(convert(char(8), getdate() + @DateOffset, 112) as datetime)
	

	select 
		RV.RID, 
		RName, 
		City, 
		State, 
		Left(cast(COALESCE(RA.DateAdded, '')as varchar(11)),11) as LiveDate,
		RV.shiftdate 'ShiftDate',
		sum(Case when RstateID in (1,2,5,6,7) then 1 else 0 end) [Total Reservations], 
		sum(Case when RstateID in (1,2,5,6,7) then BillableSize else 0 end) [Total Guests],
		sum(Case when RstateID in (1,2,5,6,7) and FirstTime = 1 then 1 else 0 end) [Total First Time Reservations],
		sum(Case when RstateID in (1,2,5,6,7) then billableSize*Cast(FirstTime as int) else 0 end) as [Covers From First Time Reservations],
		sum((Case when RstateID in (1,2,5,6,7) and billingType='RestRefReso'then 1 else 0 end)) [Restaurant Website Reservations],
		sum(billableSize*(Case when RstateID in (1,2,5,6,7) and billingType='RestRefReso'then 1 else 0 end)) as [Restaurant Website Guests],
		sum((Case when RstateID in (1,2,5,6,7) and billingType='OTReso'then 1 else 0 end)) [OpenTable Reservations],
		sum(billableSize*(Case when RstateID in (1,2,5,6,7) and billingType='OTReso'then 1 else 0 end)) as [OpenTable Guests],
		sum((Case when RstateID in (1,2,5,6,7) and billingType='DIPReso'then 1 else 0 end)) [Promo Reservations],
		sum(billableSize*(Case when RstateID in (1,2,5,6,7) and billingType='DIPReso'then 1 else 0 end)) as [Promo Guests],
		sum((Case when RstateID in (1,2,5,6,7) and billingType= 'RestRefReso' and FirstTime = 1 then 1 else 0 end))  [First Time Restaurant Website Reservations],
		sum((Case when RstateID in (1,2,5,6,7) and billingType='OTReso' and FirstTime = 1 then 1 else 0 end))  [First Time OpenTable Reservations],
		sum((Case when RstateID in (1,2,5,6,7) and billingType='DIPReso' and FirstTime = 1 then 1 else 0 end)) [First Time Promo Reservations],
		sum(billableSize*(case when RstateID in(6,7) then 1 else 0 end)) [Dispute Covers],
		sum((case when RstateID in(3,8,9) then 1 else 0 end)) [Cancellations],
		sum( case when RstateID in(3,8,9) and billingType= 'RestRefReso' then 1 else 0 end) [RestaurantReservationCancellation],
		sum( case when RstateID in(3,8,9) and billingType= 'OTReso' then 1 else 0 end) [OTReservationCancellation],
		sum( case when RstateID in(3,8,9) and billingType= 'DIPReso' then 1 else 0 end) [PromoReservationCancellation],
		sum((case when RstateID in(4,10) then 1 else 0 end)) [No Shows],
		sum( case when RstateID in(4,10) and billingType= 'RestRefReso' then 1 else 0 end) [RestaurantReservationNoShow],
		sum( case when RstateID in(4,10) and billingType= 'OTReso' then 1 else 0 end) [OTReservationNoShow],
		sum( case when RstateID in(4,10) and billingType= 'DIPReso' then 1 else 0 end) [PromoReservationNoShow]
	from		reservationvw RV
	left join	restaurantJustAdded RA
	on			RV.RID = RA.RID
	where		RV.RID in (select distinct RID 
							from restaurantToGroup 
							where GID =  @GID)
	and			RV.shiftdate >= @startDT and RV.shiftdate < @endDT
	group by	RV.RID, Rname, city, state, RA.DateAdded, RV.shiftdate
	order by	RName, City, State

GO

GRANT EXECUTE ON [JobGroupReportDailyExcelExport] TO ExecuteOnlyRole
GRANT EXECUTE ON [JobGroupReportDailyExcelExport] TO DTR_User

GO
