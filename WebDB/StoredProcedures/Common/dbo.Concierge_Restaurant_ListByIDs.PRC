if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_ListByIDs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_ListByIDs]
GO

CREATE PROCEDURE dbo.Concierge_Restaurant_ListByIDs
 (
  @GeoID int,
  @Restaurants nvarchar(255),
  @ResDateTime datetime
 )

As

--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare  @time_offset real,@LeadTime as nvarchar(30),@LeadTime_value as int,@meal_period as
nvarchar(30),@ServerTZID as int,@SameDayReso as int

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

select @LeadTime = '30 minutes'
select @LeadTime_value = 30

SELECT r.RID AS RestaurantID,
    r.RName AS RestaurantName,
    ERBRestaurant.ServerIP AS NetAddress,
    ERBRestaurant.serverPwd AS Password,
    tz._offsetHR AS TimeZoneOffset,
    (select _offsetHR from TimeZone where TZID = r.TZID )-(select _offsetHR from TimeZone where TZID = 7) As RealTimeOffset,
    moo.MinValue AS MinPartySize,
    mxo.MaxValue AS MaxPartySize,
    mao.Days AS MaxAdvance,
    mao.MaxAdvanceOption AS MaxAdvanceDescription,
    r.RName AS R,r.createdate AS T1,
    r.createdate AS T2,
    r.createdate AS T3,
    r.createdate AS SortOrder,
    r.Address1 AS Address,
    r.City AS City,
    r.State AS State,
    r.Zip AS Zip,
    n.NbhoodName AS NeighborhoodName,
    r.PriceQuartileID AS Price_Quartile_ID,

    @LeadTime as lead_time,
 (CASE
 WHEN (dateadd(minute,@LeadTime_value,(dateadd(Hour,( (select _offsetHR from timezone
 where TZID = r.TZID)-
 (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()))) -
 @ResDateTime) < 0 then 1 ELSE 0 END)
 as LeadTime_ok,

 (CASE
 WHEN (cast(CONVERT(nvarchar,dateadd(Hour,( (select _offsetHR from TimeZone where TZID =
 r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()),108) as datetime) -
 isnull(ShiftTemplate.ResCutOffTime, cast('11:59 PM' as datetime))) < 0
 then 0 ELSE 1 END)--if positive,then after cutoff
 as aftercutoff,
--get cutoff_time
  Right(cast(ShiftTemplate.ResCutOffTime as nvarchar(20)),7)  as
cutoff_time,
--is this a same day reso?
 (CASE
 WHEN (cast(CONVERT(nvarchar,@ResDateTime,110) as datetime) -- mm-dd-yyyy
 - cast(CONVERT(nvarchar,(dateadd(Hour,( (select _offsetHR from TimeZone where
 TZID = r.TZID)-
     (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate())),
110) as datetime)) = 0
   then 1 ELSE 0 END)
 as samedayreso,
  --get meal_period

 CASE ShiftTemplate.ShiftID
 when 1 then 'lunch'
 when 2 then 'dinner'
 when 3 then 'breakfast'
 when 4 then 'brunch'
 ELSE ''
 END

 as meal_period

FROM		RestaurantVW r 
INNER JOIN	NeighborhoodAVW n 
ON			r.neighborhoodid = n.neighborhoodid 
and			n.LanguageID = r.LanguageID
INNER JOIN TimeZone tz 
ON			r.TZID = tz.TZID 
INNER JOIN	ERBRestaurant 
ON			r.RID = ERBRestaurant.RID 
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
ON  r.RID = ScheduleShifts.RID
WHERE (n.metroareaid = @GeoID)
AND (r.RestStateID = 1)
AND ((r.IsReachable = 1) or ( r.Allotment = 1 and r.RestStateID = 1))
AND ((LEN(@Restaurants) = 0 OR CHARINDEX(',' + CAST(r.RID AS nvarchar(16)) + ',',',' + @Restaurants + ',') > 0))
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
GO

GRANT EXECUTE ON [Concierge_Restaurant_ListByIDs] TO ExecuteOnlyRole

GO
