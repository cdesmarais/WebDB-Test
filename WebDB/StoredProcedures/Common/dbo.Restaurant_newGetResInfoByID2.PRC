if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_newGetResInfoByID2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_newGetResInfoByID2]
GO

CREATE Procedure dbo.Restaurant_newGetResInfoByID2
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

declare @EarlyCutoffRIDWhitelistMasterID int = 89
DECLARE @EarlyCutoff int 
	= coalesce((SELECT 1 from ValueLookupIDList where LookupID = @EarlyCutoffRIDWhitelistMasterID and ValueID = @RestaurantID), 0)
DECLARE @EarlyCutoffDays int
	= coalesce((SELECT ValueInt from ValueLookup where LKey = 'EarlyCutoffDays'), 7)


SELECT  Right( convert(nvarchar, ShiftTemplate.ResCutOffTime,100),7) AS CutoffTime,
	(CASE
	WHEN (( dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)-
     	(select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()) )
	 > @ResDateTime)
	THEN 1
	ELSE 0
	END) as InThePast,

--check lead time
	(CASE
	WHEN
		(dateadd(minute,@LeadTime_value,(dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)-
		(select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()))) - @ResDateTime) < 0
	THEN 1
	ELSE 0
	END) as LeadTimeOk,


--is this a same day reso?
	(CASE WHEN
                  	   (cast(CONVERT(nvarchar,@ResDateTime,110) as datetime)
	     	   - cast(CONVERT(nvarchar,(dateadd(Hour,( (select _offsetHR from TimeZone where TZID = r.TZID)-
    	    	   (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate())),110) as datetime)) = 0
               THEN 1
	  ELSE 0
 	  END) as samedayreso,


--is the reso time after the cutoff? - only valid if this is a samedayreso
	(CASE WHEN (cast(CONVERT(nvarchar,dateadd(Hour,( (select _offsetHR from TimeZone where TZID =
		   r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()),108) as datetime) -
		   isnull(ShiftTemplate.ResCutOffTime, cast('11:59 PM' as datetime))) < 0
	  THEN 0
	  ELSE 1
	  END) as AfterCutoffTime,

--do we hit an early cutoff
	(case
		WHEN @EarlyCutoff = 0 THEN 0
		WHEN @EarlyCutoffDays <= 0 THEN 0
		when (
				-- cutoff is midnight (23:59 + 1) 7 days before, equivalently 00:00 6 days before
				dateadd(day, 1 - @EarlyCutoffDays, convert(datetime, convert(date,@ResDateTime)))
				<
				-- local time now at restaurant
				dateadd(Hour,
						( (select _offsetHR from TimeZone where TZID = r.TZID) - (select _offsetHR from TimeZone where TZID = @ServerTZID)),
						getDate()))
		then 1
		else 0
	end) as EarlyCutoff,

  --get meal_period

	CASE ShiftTemplate.ShiftID

	when 1 then 'lunch'
	when 2 then 'dinner'
	when 3 then 'breakfast'
	when 4 then 'brunch'
	ELSE ''
	END  as meal_period

FROM Restaurant r

LEFT OUTER JOIN (ScheduleShifts Inner join ShiftTemplate ON
	ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
	and ScheduleShifts.scheduleID = datepart(dw,@ResDateTime) -- day of week
	and ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
	and ScheduleShifts.ShiftID = ShiftTemplate.ShiftID
	and ShiftTemplate.CutoffActive = 1
  	and ShiftTemplate.OpenTime <= cast(CONVERT(nvarchar,@ResDateTime,108) as datetime)
  	and ShiftTemplate.CloseTime >= cast(CONVERT(nvarchar,@ResDateTime,108) as datetime))

ON  r.RID = ScheduleShifts.RID

WHERE r.RID = @RestaurantID
GO

GRANT EXECUTE ON [Restaurant_newGetResInfoByID2] TO ExecuteOnlyRole

GO
