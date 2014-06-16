if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_GetResInfoByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_GetResInfoByID]
GO

CREATE PROCEDURE dbo.Concierge_Restaurant_GetResInfoByID
 (
  @RestaurantID int,
  @ResDateTime datetime
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare  @LeadTime as nvarchar(30),@LeadTime_value as int,@meal_period as nvarchar(30),

@ServerTZID as int,@SameDayReso as int


exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

select @LeadTime = '30 minutes'  --this will be changed to 'lead time' in future...
select @LeadTime_value = 30


SELECT  r.RID AS RestaurantID,
    r.RName AS RestaurantName,
    er.ServerIP AS NetAddress,
    er.serverPwd AS Password,
    tz._offsetHR AS TimeZoneOffset,
    moo.MinValue AS MinPartySize,
    mxo.MaxValue AS MaxPartySize,
    mao.Days AS MaxAdvance,
    mao.MaxAdvanceOPtion AS MaxAdvanceDescription,
    r.RName AS R,r.createdate AS T1,
    r.createdate AS T2,
    r.createdate AS T3,
    r.createdate AS SortOrder,
    (select _offsetHR from TimeZone where TZID = r.TZID )-
    (select _offsetHR from TimeZone where TZID = @ServerTZID) As RealTimeOffset,

    r.Address1 AS Address,
    r.City AS City,
    r.State AS State,
    r.Zip AS Zip,
    n.NbhoodName AS NeighborhoodName,
    r.PriceQuartileID AS Price_Quartile_ID,
    @LeadTime as lead_time,

	(CASE
	WHEN (dateadd(minute,@LeadTime_value,(dateadd(Hour,((select _offsetHR from timezone where TZID = r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()))) - @ResDateTime) < 0 then 1 ELSE 0 END)
	as LeadTime_ok,
--is the reso time after the cutoff? - only valid if this is a samedayreso
	(CASE
	WHEN (cast(CONVERT(nvarchar,dateadd(Hour,( (select _offsetHR from TimeZone where TZID =

	r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()),108) as datetime) -
	isnull(ShiftTemplate.ResCutOffTime, cast('11:59 PM' as datetime))) < 0
	then 0 ELSE 1 END)--if positive,then after cutoff
	as aftercutoff,
  --get cutoff_time
	 Right(cast(ShiftTemplate.ResCutOffTime as nvarchar(20)),7)	 as

cutoff_time,
--is this a same day reso?
	(CASE
	WHEN (cast(CONVERT(nvarchar,@ResDateTime,110) as datetime) -- mm-dd-yyyy
	- cast(CONVERT(nvarchar,(dateadd(Hour,( (select _offsetHR from TimeZone where

TZID = r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate())),110) as datetime)) = 0
	  then 1 ELSE 0 END)
	as samedayreso
	,CASE ShiftTemplate.ShiftID
	when 1 then 'lunch'
	when 2 then 'dinner'
	when 3 then 'breakfast'
	when 4 then 'brunch'
	ELSE ''
	END
	as meal_period

FROM RestaurantVW r
INNER JOIN NeighborhoodAVW n 
ON			r.neighborhoodid = n.neighborhoodid 
and			r.LanguageID = n.LanguageID
INNER JOIN ERBRestaurant er
ON			r.RID = er.RID 
INNER JOIN TimeZone tz
ON			r.TZID = tz.TZID 
INNER JOIN MinOnlineOption moo
ON r.MinOnlineOptionID = moo.MinOnlineOptionID
INNER JOIN MaxOnlineOption mxo
ON r.MaxLargePartyID = mxo.MaxOnlineOptionID
INNER JOIN MaxAdvanceOption mao
ON r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
    

LEFT OUTER JOIN (scheduleshifts Inner join ShiftTemplate ON
ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
and ScheduleShifts.scheduleID = datepart(dw,@ResDateTime) -- day of week
and ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
and ScheduleShifts.ShiftID = ShiftTemplate.ShiftID
and ShiftTemplate.CutoffActive = 1
and ShiftTemplate.OpenTime <= cast(CONVERT(nvarchar,@ResDateTime,108) as datetime)
and ShiftTemplate.CloseTime >= cast(CONVERT(nvarchar,@ResDateTime,108) as datetime))

ON r.RID = ScheduleShifts.RID
WHERE r.RID = @RestaurantID

GO

GRANT EXECUTE ON [Concierge_Restaurant_GetResInfoByID] TO ExecuteOnlyRole

GO
