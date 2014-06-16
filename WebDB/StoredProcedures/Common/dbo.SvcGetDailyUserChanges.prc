if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetDailyUserChanges]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcGetDailyUserChanges]
GO


CREATE PROCEDURE dbo.SvcGetDailyUserChanges
(
	@StartDateUTC datetime,
	@EndDateUTC	datetime
)
as
/*
	Note that the UpdatedDate for customer/caller records are all UTC.  In order to
	capture the latest records for a given day behind snapshot, we need to adjust
	the date Midnight PT since that's when we create the day behind.

	Query users that have changed any of these fields:
	
	FName 
	LName 
	MetroAreaID 
	Email						
	SendAnnouncements 
	Active
	ConsumerType
	
	OR
	
	Any users that have had a seated reso within the date range given.
*/
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @startday datetime, @endday datetime, @StartTimeUTC datetime, @EndTimeUTC datetime, @UTCMIDiff int

--Get the offset for the UTC comparisons
select			top 1 @UTCMIDiff = (ServerOffsetMI * -1)
from			TimezoneVW

set @startday = dbo.fGetDatePart(@StartDateUTC)
set @endday = dbo.fGetDatePart(@EndDateUTC)
set @StartTimeUTC = dateadd(MI,@UTCMIDiff,@StartDateUTC)
set @EndTimeUTC = dateadd(MI,@UTCMIDiff,@EndDateUTC)

--Make sure no previous versions of the tables exist
if object_id('tempdb..#TempCust') is not null 
	drop table #TempCust
	
if object_id('tempdb..#TempCaller') is not null 					
	drop table #TempCaller
	
if object_id('tempdb..#TempSubscriber') is not null 					
	drop table #TempSubscriber	

--Temp tables to hold the records identified for customers
--and callers within the date window specified by input params
create table #TempCust
(
	CustID	int primary key,
	ResID int
)
--Create an index on the ResID to assist performance
create nonclustered index TempCust_ResID_NC
on #TempCust(ResID)

create table #TempCaller
(
	CallerID int primary key,
	ResID int
)
--Create an index on the ResID to assist performance
create nonclustered index TempCaller_ResID_NC
on #TempCaller(ResID)

create table #TempSubscriber
(
	CustID int primary key
)

--Store the records that are relevant to the date window
insert into				#TempCust
	select				CustID, max(ResID)
	from (
		select			c.CustID,
						--Obtain the last resid for a seated reso for this
						--customer.  This may be null.
						(
							select		max(r.ResID)
							from		Reservation r
							where		r.CustID = c.CustID
							and			r.RStateID in (2,5,6,7)							
						) ResID
		from 			Customer c	
		left join		CustomerPhone cp
		on				c.CustID = cp.CustID
		and				cp.IsPrimary = 1
		left join 		UserOptIn uo
		on 				c.CustID = uo.CustID
		where			c.ConsumerType in (1,4,5)
		and				(
							c.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
							or
							cp.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
							or
							uo.UpdatedDtUTC between @StartTimeUTC and @EndTimeUTC
						)
		and				len(ltrim(rtrim(c.Email))) > 0
	union --Find the registered users who have a seated ShiftDate within the window specified.
	select				c.CustID,
						r.ResID
	from				Reservation r
	inner join			Customer c
	on					r.CustID = c.CustID
	where				r.CallerID is null
	and					r.ShiftDate >= @startday 
	and					r.ShiftDate < @endday
	-- Allow for pending RStateID=1 since pending resos in the past are assumed seated
	and					r.RStateID in (1,2,5,6,7)
	and					c.ConsumerType in (1,4,5)
	and					len(ltrim(rtrim(c.Email))) > 0
	) AllCust
	group by CustID

--Repeat the same process for the caller
insert into				#TempCaller
	select				CallerID, max(ResID)
	from (
		select			c.CallerID,
						(
							select		max(r.ResID)
							from		Reservation r
							where		r.CallerID = c.CallerID
							and			r.RStateID in (2,5,6,7)
						) ResID
	from 				Caller c	
	left join			CallerPhone cp
	on					c.CallerID = cp.CallerID
	and					cp.IsPrimary = 1
	left join 			UserOptIn uo
	on 					c.CallerID = uo.CallerID
	where				c.ConsumerType in (1,4,5)
	and					c.PositionID != 2 --Exclude concierge users
	and					(
							c.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
							or
							cp.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
							or
							uo.UpdatedDtUTC between @StartTimeUTC and @EndTimeUTC
						)
	and					len(ltrim(rtrim(c.Email))) > 0
	union
	select				c.CallerID,
						r.ResID
	from				Reservation r
	inner join			Caller c
	on					r.CallerID = c.CallerID
	where				r.ShiftDate >= @startday
	and					r.ShiftDate < @endday
	and					r.RStateID in (1,2,5,6,7)
	and					c.ConsumerType in (1,4,5)
	and					len(ltrim(rtrim(c.Email))) > 0
	and					c.PositionID != 2 --Exclude concierge users
	) AllCaller
	group by CallerID
	
-- Repeat process for Email Subscribers ( really Anonymous users with newsletter optins ie Townhog and UrbanDaddy user)
--Store the records that are relevant to the date window
insert into				#TempSubscriber
		select			c.CustID
		from 			Customer c	
		inner join 		UserOptIn uo
		on 				c.CustID = uo.CustID
						AND c.MetroAreaID = uo.MetroAreaID 
		where			c.ConsumerType = 8
		and				(
							c.UpdatedUTC between @StartTimeUTC and @EndTimeUTC
							or
							uo.UpdatedDtUTC between @StartTimeUTC and @EndTimeUTC
						)
		and				len(ltrim(rtrim(c.Email))) > 0

	
-- Here we create the return set for the stored proc.  This is the data
-- that will be transformed into a CSV file and put onto the EmailProvider's
-- system.
select					c.Email,
						c.FName first_name,
						c.LName last_name,
						c.MetroAreaID Metro_area_id,
						c.SendAnnouncements OptInStatus,
						c.Points,
						ct.ConsumerTypeTypeName UserType,
						null AdminType,
						substring(cp.Phone,1,3) AreaCode,
						convert(nvarchar(10),r.Shiftdate,101) LastSeatedResoDate,
						r.RID LastSeatedRID,
						rt.RName LastSeatedRestName,
						r.ReferrerID,
						tc.CustID UserID,
						convert(nvarchar(10),isnull(CDate.ConvertDate,c.CreateDate),101) RegDate,						
						convert
						(
							nvarchar(10),
							(	case when isnull(CDate.ConvertDate,c.CreateDate) > epwmc.StartDate 
								then isnull(CDate.ConvertDate,c.CreateDate) 
								else null end),
							101
						) WelcomeEmailDate,
						(case when c.Active = 1 then 'Active' else 'Inactive' end) Status,
						c.SendPromoEmail SubscribeStatus,
						cast(coalesce(uo.SpotLight,1) as bit) SpotlightStatus,
						cast(coalesce(uo.Insider,1) as bit) InsiderNewsStatus,
						cast(coalesce(uo.DinersChoice,1) as bit) DinersChoiceStatus,		
						cast(coalesce(uo.NewHot,1) as bit) NewHotStatus,		
						cast(coalesce(uo.RestaurantWeek,1) as bit) RestaurantWeekStatus,		
						cast(coalesce(uo.Promotional,1) as bit) PromotionalStatus,								
						cast(coalesce(uo.Product,1) as bit) ProductStatus		
						from #TempCust tc
						inner join Customer c
						on tc.CustID = c.CustID
						inner join ConsumerTypes ct
						on c.ConsumerType = ct.ConsumerTypeID
						left join CustomerPhone cp
						on tc.CustID = cp.CustID
						and cp.IsPrimary = 1
						left join	(	select		min(ctcl.ConvertDate) ConvertDate, ctcl.CustID 
										from		ConsumerTypeConvertLog ctcl
										inner join	#TempCust tcx
										on			ctcl.CustID = tcx.CustID
										where		ctcl.NewConsumerTypeID = 1
										and			ctcl.OriginalConsumerTypeID = 8
										and			ctcl.CallerID is null
										group by ctcl.CustID
						) CDate
						on tc.CustID = CDate.CustID
						left join ReservationVW r
						on tc.ResID = r.ResID
						left join RestaurantVW rt
						on r.RID = rt.RID
						left join EmailProviderWelcomeMailConfig epwmc
						on c.MetroAreaID = epwmc.MetroAreaID
						left join UserOptIn uo
						on tc.CustID = uo.CustID AND c.MetroAreaID = uo.MetroAreaID
union all
select					c.Email,
						c.FName first_name,
						c.LName last_name,
						c.MetroAreaID Metro_area_id,
						c.SendAnnouncements OptInStatus,
						c.Points,
						ct.ConsumerTypeTypeName UserType,
						p.PositionName AdminType,
						substring(cp.Phone,1,3) AreaCode,
						convert(nvarchar(10),r.Shiftdate,101) LastSeatedResoDate,
						r.RID LastSeatedRID,
						rt.RName LastSeatedRestName,
						r.ReferrerID,
						tc.CallerID * -1 UserID,
						convert(nvarchar(10),isnull(CDate.ConvertDate,c.CreateDate),101) RegDate,
						convert
						(
							nvarchar(10),	
							(case when isnull(CDate.ConvertDate,c.CreateDate) > epwmc.StartDate then isnull(CDate.ConvertDate,c.CreateDate) else null end),
							101
						) WelcomeEmailDate,
						(case when c.CallerStatusID = 1 then 'Active' else 'Inactive' end) Status,
						c.SendPromoEmail SubscribeStatus,
						cast(coalesce(uo.SpotLight,1) as bit) SpotlightStatus,
						cast(coalesce(uo.Insider,1) as bit) InsiderNewsStatus,
						cast(coalesce(uo.DinersChoice,1) as bit) DinersChoiceStatus,		
						cast(coalesce(uo.NewHot,1) as bit) NewHotStatus,		
						cast(coalesce(uo.RestaurantWeek,1) as bit) RestaurantWeekStatus,		
						cast(coalesce(uo.Promotional,1) as bit) PromotionalStatus,			
						cast(coalesce(uo.Product,1) as bit) ProductStatus		
						from #TempCaller tc
						inner join Caller c
						on tc.CallerID = c.CallerID
						inner join ConsumerTypes ct
						on c.ConsumerType = ct.ConsumerTypeID
						inner join Position p
						on c.PositionID = p.PositionID
						left join CallerPhone cp
						on tc.CallerID = cp.CallerID
						and cp.IsPrimary = 1
						left join	(	select		min(ctcl.ConvertDate) ConvertDate, ctcl.CallerID 
										from		ConsumerTypeConvertLog ctcl
										inner join	#TempCaller tcx
										on			ctcl.CallerID = tcx.CallerID
										where		ctcl.NewConsumerTypeID = 1
										and			ctcl.OriginalConsumerTypeID = 8
										and			ctcl.CallerID is null
										group by	ctcl.CallerID
						) CDate
						on tc.CallerID = CDate.CallerID						
						left join ReservationVW r
						on tc.ResID = r.ResID
						left join RestaurantVW rt
						on r.RID = rt.RID
						left join EmailProviderWelcomeMailConfig epwmc
						on c.MetroAreaID = epwmc.MetroAreaID
						left join UserOptIn uo
						on tc.CallerID = uo.CallerID AND c.MetroAreaID = uo.MetroAreaID
union all
select					c.Email,
						null first_name,
						null last_name,
						c.MetroAreaID Metro_area_id,
						null OptInStatus,
						null Points,
						ct.ConsumerTypeTypeName UserType,
						null AdminType,
						null AreaCode,
						null LastSeatedResoDate,
						null LastSeatedRID,
						null LastSeatedRestName,
						null ReferrerID,
						tc.CustID UserID,
						null RegDate,						
						null WelcomeEmailDate,
						(case when c.Active = 1 then 'Active' else 'Inactive' end) Status,
						null SubscribeStatus,
						uo.SpotLight SpotlightStatus,
						uo.Insider InsiderNewsStatus,
						uo.DinersChoice DinersChoiceStatus,		
						uo.NewHot NewHotStatus,		
						uo.RestaurantWeek RestaurantWeekStatus,		
						uo.Promotional PromotionalStatus,								
						uo.Product ProductStatus		
						from #TempSubscriber tc
						inner join Customer c
						on tc.CustID = c.CustID
						inner join ConsumerTypes ct
						on c.ConsumerType = ct.ConsumerTypeID
						inner join UserOptIn uo
						on tc.CustID = uo.CustID AND c.MetroAreaID = uo.MetroAreaID
						

		if object_id('tempdb..#TempCust') is not null 
			drop table #TempCust
			
		if object_id('tempdb..#TempCaller') is not null 					
			drop table #TempCaller

		if object_id('tempdb..#TempSubscriber') is not null 					
			drop table #TempSubscriber			
GO			
		

GRANT EXECUTE ON [SvcGetDailyUserChanges] TO ExecuteOnlyRole
GO
