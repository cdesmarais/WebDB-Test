if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationService_GetReservationCutoffs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationService_GetReservationCutoffs]
GO

CREATE Procedure dbo.ReservationService_GetReservationCutoffs
 (
  @RestaurantID int,
  @ResDateTime datetime
 )
As

set transaction isolation level read uncommitted

Declare  @LeadTime as nvarchar,
@LeadTime_value as int,
@meal_period as nvarchar,
@ServerTZID as int,
@SameDayReso as int

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

select @LeadTime = '5 minutes'  
select @LeadTime_value = 5

declare @EarlyCutOffDaysCancel int = coalesce((SELECT SuppressionDays from dbo.RestaurantSuppression where RID = @RestaurantID AND RestaurantSuppressionTypeId = 1), 0)
declare @EarlyCutOffDaysMake int = coalesce((SELECT SuppressionDays from dbo.RestaurantSuppression where RID = @RestaurantID AND RestaurantSuppressionTypeId = 2), 0)
declare @EarlyCutOffDaysChange int = coalesce((SELECT SuppressionDays from dbo.RestaurantSuppression where RID = @RestaurantID AND RestaurantSuppressionTypeId = 3), 0)

SELECT  
	Right( convert(nvarchar, ShiftTemplate.ResCutOffTime,100),7) AS CutoffTime,
	
	(CASE
		WHEN 
			((dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)
				- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()))
		 > @ResDateTime)
		THEN 1
		ELSE 0
		END) as InThePast,

	--check lead time
	(CASE
		WHEN
			(dateadd(minute,@LeadTime_value,(dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)
				- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()))) - @ResDateTime)
			< 0
		THEN 1
		ELSE 0
		END) as LeadTimeOk,

	--is this a same day reso?
	(CASE 
		WHEN
			(cast(CONVERT(nvarchar,@ResDateTime,110) as datetime)
				- cast(CONVERT(nvarchar,(dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)
				- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate())),110) as datetime))
			= 0
		THEN 1
		ELSE 0
		END) as samedayreso,

	--is the reso time after the cutoff? - only valid if this is a samedayreso
	(CASE 
		WHEN 
			(cast(CONVERT(nvarchar,dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)
				- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()),108) as datetime)
				- isnull(ShiftTemplate.ResCutOffTime, cast('11:59 PM' as datetime))) 
			< 0
	  THEN 0
	  ELSE 1
	  END) as AfterCutoffTime,

	--is early cutoff for Make
	(case
		WHEN @EarlyCutoffDaysMake <= 0 THEN 0
		WHEN (
				-- cutoff is midnight (23:59 + 1) 7 days before, equivalently 00:00 6 days before
				dateadd(day, 1 - @EarlyCutoffDaysMake, convert(datetime, convert(date,@ResDateTime)))
				<
				-- local time now at restaurant
				dateadd(
					Hour,
					((select _offsetHR from TimeZone where TZID = r.TZID) 
							- (select _offsetHR from TimeZone where TZID = @ServerTZID)),
					getDate()))
		then 1
		else 0
	end) as EarlyCutoffMake,
	
	--is early cutoff for Cancel
	(case
		WHEN @EarlyCutoffDaysCancel <= 0 THEN 0
		WHEN (
				-- cutoff is midnight (23:59 + 1) 7 days before, equivalently 00:00 6 days before
				dateadd(day, 1 - @EarlyCutoffDaysCancel, convert(datetime, convert(date,@ResDateTime)))
				<
				-- local time now at restaurant
				dateadd(Hour,
						( (select _offsetHR from TimeZone where TZID = r.TZID) - (select _offsetHR from TimeZone where TZID = @ServerTZID)),
						getDate()))
		then 1
		else 0
	end) as EarlyCutoffCancel,

	--is early cutoff for Change
	(CASE
		WHEN 
			@EarlyCutoffDaysChange <= 0 THEN 0
		WHEN (
			-- cutoff is midnight (23:59 + 1) 7 days before, equivalently 00:00 6 days before
			dateadd(day, 1 - @EarlyCutoffDaysChange, convert(datetime, convert(date,@ResDateTime)))
			<
			-- local time now at restaurant
			dateadd(Hour,
					( (select _offsetHR from TimeZone where TZID = r.TZID) - (select _offsetHR from TimeZone where TZID = @ServerTZID)),
					getDate())
		)
		then 1
		else 0
	end) as EarlyCutoffChange,

	--get meal_period
	CASE ShiftTemplate.ShiftID
		when 1 then 'lunch'
		when 2 then 'dinner'
		when 3 then 'breakfast'
		when 4 then 'brunch'
		ELSE ''
	END  as meal_period,

	-- Number of CutfOff days for Make Reservation
	@EarlyCutoffDaysMake AS EarlyCutoffDaysMake,
	
	-- Number of CutfOff days for Cancel Reservation	
	@EarlyCutoffDaysCancel AS EarlyCutoffDaysCancel,
	
	-- Number of Early CutfOff days for Change Reservation
	@EarlyCutoffDaysChange AS EarlyCutoffDaysChange

FROM dbo.Restaurant r

LEFT OUTER JOIN (
	dbo.ScheduleShifts 
	Inner join dbo.ShiftTemplate ON
		ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
		and ScheduleShifts.scheduleID = datepart(dw,@ResDateTime) -- day of week
		and ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
		and ScheduleShifts.ShiftID = ShiftTemplate.ShiftID
		and ShiftTemplate.CutoffActive = 1
		and ShiftTemplate.OpenTime <= cast(CONVERT(nvarchar,@ResDateTime,108) as datetime)
		and ShiftTemplate.CloseTime >= cast(CONVERT(nvarchar,@ResDateTime,108) as datetime)
	)

ON  r.RID = ScheduleShifts.RID
WHERE r.RID = @RestaurantID
GO

GRANT EXECUTE ON [ReservationService_GetReservationCutoffs] TO ExecuteOnlyRole
GO
