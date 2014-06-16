if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobGroupReportWeeklyExcelExport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobGroupReportWeeklyExcelExport]
GO


create  Procedure [dbo].[JobGroupReportWeeklyExcelExport]
(
  @GID int,
  @DateOffset int
)
AS

	-- This Report is to summarize the same metrics as our Monthly Group Report
	-- GID - GroupID (You can find GID in RestaurantGroup Table in WEBDB)
	-- DateOffset - 0 represent report date period between yesterday and a week from yesterday

	-- All "First Time" columns will not be displayed in the report per TT30621
	set transaction isolation level read uncommitted

	Declare @weekof as varchar(12)
	set @weekof = left(cast(cast(getdate()as int)+(@DateOffset-8) as datetime),12)

	select 
		RV.RID, 
		RName, 
		City, 
		State, 
		Left(cast(COALESCE(RA.DateAdded, '')as varchar(11)),11) as LiveDate,
		@weekof [Week Of],
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
	and			RV.shiftdate between cast(cast(getdate()as int)+(@DateOffset-8) as datetime) 
	and			cast(cast(getdate()as int)+(@DateOffset-1) as datetime)
	group by	RV.RID, Rname, city, state, RA.DateAdded
	order by	RName, City, State

GO


GRANT EXECUTE ON [JobGroupReportWeeklyExcelExport] TO ExecuteOnlyRole
GRANT EXECUTE ON [JobGroupReportWeeklyExcelExport] TO DTR_User

GO

