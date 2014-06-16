if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetDailyLastResoFeedChanges]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].SvcGetDailyLastResoFeedChanges
GO

-- For each user that has a reso whose shift date falls within the date range given, 
-- extract the most  recent of those resos.  
-- Note: date range given is relative to local restaurant time,
-- from 0:00 AM of start of range to 0:00 AM of end of range, excluding the end point.

CREATE PROCEDURE dbo.SvcGetDailyLastResoFeedChanges
(
	@StartResoDateRange datetime,
	@EndResoDateRange datetime
)
as
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @startday datetime, @endday datetime

-- Normalize date range parameters:  lop off time component, if any
set @startday = dbo.fGetDatePart(@StartResoDateRange)
set @endday = dbo.fGetDatePart(@EndResoDateRange)

--Make sure no previous versions of the temp tables exist
if object_id('tempdb..#TempCust') is not null 
	drop table #TempCust
	
if object_id('tempdb..#TempCaller') is not null 					
	drop table #TempCaller

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

--Store the records that are relevant to the date window
insert into				#TempCust

	select				CustID,
						max(ResID)
	from (
		select			c.CustID,
						r.ResID									
		from			Reservation r
		inner join		Customer c
			on			r.CustID = c.CustID
				left join dbo.Attribution_FirstInLastIn a on r.ResID = a.ResID
				left join dbo.PartnerWhiteLabel p on a.PartnerIDLastIn = p.PartnerID
		where			r.CallerID is null
			and			r.ShiftDate >= @startday 
			and			r.ShiftDate < @endday
			-- Allow for pending RStateID=1 since pending resos in the past are assumed seated
			and			r.RStateID in (1,2,5,6,7)
			and			c.ConsumerType in (1,4,5,8)
			and			len(ltrim(rtrim(c.Email))) > 0 
   			and			p.PartnerID is null
	) CustResos
	
	group by CustID

--Repeat the same process for the caller
insert into				#TempCaller

	select				CallerID,
						max(ResID)
	from (
		select			c.CallerID,
						r.ResID
		from			Reservation r
		inner join		Caller c
			on			r.CallerID = c.CallerID
				left join dbo.Attribution_FirstInLastIn a on r.ResID = a.ResID
				left join dbo.PartnerWhiteLabel p on a.PartnerIDLastIn = p.PartnerID
		where			r.ShiftDate >= @startday
			and			r.ShiftDate < @endday
			and			r.RStateID in (1,2,5,6,7)
			and			c.ConsumerType in (1,4,5,8)
			and			len(ltrim(rtrim(c.Email))) > 0
			and			c.PositionID != 2 --Exclude concierge users 
   			and			p.PartnerID is null
	) CallerResos
	
	group by CallerID
		
-- Here we create the return set for the stored proc.  This is the data
-- that will be transformed into a CSV file 

	select				tc.CustID									as UserID,
						convert(nvarchar(10),reso.Shiftdate,101)	as ResoDate,
						reso.RID									as RID,
						rest.RName									as RestName,
						reso.ReferrerID								as ReferrerID
						
	from				#TempCust tc
	inner join			ReservationVW reso
		on				tc.ResID = reso.ResID
	left join			RestaurantVW rest
		on				reso.RID = rest.RID
	
				
union all

	select				ta.CallerID * -1							as UserID,
						convert(nvarchar(10),reso.Shiftdate,101)	as ResoDate,
						reso.RID 									as RID,
						rest.RName									as RestName,
						reso.ReferrerID								as ReferrerID
						
	from				#TempCaller ta
	inner join			ReservationVW reso
		on				ta.ResID = reso.ResID
	left join			RestaurantVW rest
		on				reso.RID = rest.RID


-- Cleanup: drop the temporary tables
if object_id('tempdb..#TempCust') is not null 
	drop table #TempCust
	
if object_id('tempdb..#TempCaller') is not null 					
	drop table #TempCaller
			
GO			
		

GRANT EXECUTE ON SvcGetDailyLastResoFeedChanges TO ExecuteOnlyRole

GO
