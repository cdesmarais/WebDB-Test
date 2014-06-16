if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_ListByFoodTypesPricesAndNeighborhoods]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_ListByFoodTypesPricesAndNeighborhoods]
GO

CREATE Procedure dbo.Concierge_Restaurant_ListByFoodTypesPricesAndNeighborhoods
 (
  @GeoID int,
  @FoodTypes nvarchar(255),
  @Neighborhoods nvarchar(255),
  @PriceRange nvarchar(255),
  @ResDateTime datetime
 )

As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare  @lead_time as nvarchar(30), @lead_time_value as int, @meal_period as nvarchar(30),
@ServerTimeZoneID as int, @SameDayReso as int

exec getServerTimeZoneID @retVal = @ServerTimeZoneID OUTPUT

select @lead_time = '5 minutes'  
select @lead_time_value = 5

IF @FoodTypes IS NULL SELECT @FoodTypes= ''
IF @Neighborhoods IS NULL SELECT @Neighborhoods= ''
IF @PriceRange IS NULL SELECT @PriceRange=''

SELECT DISTINCT
    r.RID AS RestaurantID,
    r.RName AS RestaurantName,
    er.ServerIP AS NetAddress,
    er.ServerPwd AS Password,
    TimeZone._offsetHR AS TimeZoneOffset,
    (select _offsetHR from TimeZone where TZID = r.TZID )- (select _offsetHR from TimeZone where TZID = 7) As RealTimeOffset,
    MinOnlineOption.MinValue AS MinPartySize,
    MaxOnlineOption.MaxValue AS MaxPartySize,
    MaxAdvanceOption.Days AS MaxAdvance,
    MaxAdvanceOption.MaxAdvanceOption AS MaxAdvanceDescription,
    r.RName AS R
    , r.CreateDate AS T1,
    r.CreateDate AS T2,
    r.CreateDate AS T3,
    r.CreateDate AS SortOrder,
    r.Address1 AS Address,
    r.City AS City,
    r.State AS State,
    r.Zip AS Zip,
    n.NbhoodName AS NeighborhoodName,
    r.PriceQuartileID as Price_Quartile_ID,
    @lead_time as lead_time,

 (CASE
 WHEN (dateadd(minute, @lead_time_value, (dateadd(Hour, ((select _offsetHR from TimeZone where TZID = r.TZID) - (select _offsetHR from TimeZone where TZID = @ServerTimeZoneID)), getDate()))) -
@ResDateTime) < 0 then 1 ELSE 0 END)
 as lead_time_ok,
 (CASE
 WHEN (cast(CONVERT(nvarchar, dateadd(Hour, ( (select _offsetHR from TimeZone where TZID =
 r.TZID)- (select _offsetHR from TimeZone where TZID = @ServerTimeZoneID)), getDate()), 108) as datetime) -
 coalesce(ShiftTemplate.ResCutoffTime,  cast('11:59 PM' as datetime))) < 0
 then 0 ELSE 1 END)
 as aftercutoff,

  Right(cast(ShiftTemplate.ResCutoffTime as nvarchar(20)), 7)  as
cutoff_time,

 (CASE
 WHEN (cast(CONVERT(nvarchar, @ResDateTime, 110) as datetime) -- mm-dd-yyyy
 - cast(CONVERT(nvarchar,(dateadd(Hour, ( (select _offsetHR from TimeZone where
TZID = r.TZID)-
     (select _offsetHR from TimeZone where TZID = @ServerTimeZoneID)), getDate())),
110) as datetime)) = 0
   then 1 ELSE 0 END)
 as samedayreso,

 CASE ShiftTemplate.ShiftID
 when 1 then 'lunch'
 when 2 then 'dinner'
 when 3 then 'breakfast'
 when 4 then 'brunch'
 ELSE ''
 END
 as meal_period
FROM RestaurantVW r
INNER JOIN  FoodTypes fts
ON          r.RID                 = fts.RID
AND         (LEN(@FoodTypes) = 0 OR CHARINDEX(',' + CAST(fts.sftid AS nvarchar(16)) + ',', ',' + @FoodTypes + ',') > 0)
inner join  foodtypes fts2
on          r.RID = fts2.RID
and         fts2.isprimary = 1
inner join  foodtype ft2
on          fts2.foodtypeid = ft2.foodtypeid
and			ft2.LanguageID = r.LanguageID
INNER JOIN	NeighborhoodAVW n 
ON			r.NeighborhoodID = n.NeighborhoodID 
and			r.LanguageID = n.LanguageID
INNER JOIN	TimeZone  
ON			r.TZID = TimeZone.TZID 
INNER JOIN	ERBRestaurant er
ON			r.RID = er.RID 
INNER JOIN	MinOnlineOption 
ON			r.MinOnlineOptionID = MinOnlineOption.MinOnlineOptionID
INNER JOIN	MaxOnlineOption 
ON			r.MaxLargePartyID = MaxOnlineOption.MaxOnlineOptionID
INNER JOIN	MaxAdvanceOption 
ON			r.MaxAdvanceOptionID = MaxAdvanceOption.MaxAdvanceOptionID
LEFT OUTER JOIN (ScheduleShifts Inner join ShiftTemplate 
ON ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
and ScheduleShifts.ScheduleID = datepart(dw, @ResDateTime)
and ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
and ScheduleShifts.ShiftID = ShiftTemplate.ShiftID
and ShiftTemplate.CutoffActive = 1
and ShiftTemplate.OpenTime <= cast(CONVERT(nvarchar, @ResDateTime, 108) as datetime)
and ShiftTemplate.CloseTime >= cast(CONVERT(nvarchar, @ResDateTime, 108) as datetime))
ON r.RID = ScheduleShifts.RID
WHERE n.MetroAreaID = @GeoID
AND (r.RestStateID = 1)
AND ((r.IsReachable = 1) or ( r.Allotment = 1 and r.RestStateID = 1)) 
AND (LEN(@Neighborhoods) = 0 OR CHARINDEX(',' + CAST(n.NeighborhoodID AS nvarchar(16)) + ',', ',' + @Neighborhoods + ',') > 0)
AND (LEN(@PriceRange) = 0 OR CHARINDEX(',' + CAST(r.PriceQuartileID AS nvarchar(16)) + ',', ',' + @PriceRange + ',') > 0)
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs

GO

GRANT EXECUTE ON [Concierge_Restaurant_ListByFoodTypesPricesAndNeighborhoods] TO ExecuteOnlyRole

GO
