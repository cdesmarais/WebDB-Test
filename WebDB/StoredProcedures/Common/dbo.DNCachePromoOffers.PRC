if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePromoOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePromoOffers]
GO


/*
This proc is used by OT_MgrCache/StoredProcTab.cs in ConsumerSite to fetch data for WebCache
*/
CREATE Procedure dbo.DNCachePromoOffers

As

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @OffersOn INT, @PrivateDiningAds INT
Select @OffersOn = coalesce(ValueInt,0) from ValueLookup where LType = 'WEBSERVER' and LKey = 'OffersOn'

Select @PrivateDiningAds = coalesce(ValueInt,0) from ValueLookup where LType = 'WEBSERVER' and LKey = 'ADS_ENABLED_PRIV_DINING'


SELECT 	ro.RID, 
		OfferName, 
		[Description], 
		coalesce(Priority,99) AS OfferOrder, 
		startDate, 
		EndDate, 
		[Days], 
		Times00_745, 
		Times08_1545, 
		Times16_2345
FROM 	RestaurantOfferVW ro
INNER JOIN 	[Restaurant] r
ON 			ro.[RID]		= r.[RID]
inner join 	TimeZoneVW tz 
on			tz.TZID					= r.TZID
WHERE 	[OfferStatusID] = 1 
AND		[DisplayOnOTWebsite] = 1
AND 	tz.CurrentLocalTime < [EndDate] + 1
AND 	@OffersOn = 1
AND		r.RestStateID not in (4,11,15)
UNION ALL
SELECT 	DISTINCT RID, 
		'Let us host your holiday party!' AS OfferName, 
		'Make your holiday event one to remember. Check out <a href="rest_profile.aspx?rid=' + CAST(rid AS VARCHAR(20)) + '&pd=1&nw=1">our private dining page</a> to see options for large parties or to make an inquiry.' AS [Description], 
		'-1' AS OfferOrder, 
		'1/1/1900' AS startDate,
		'1/1/1900' AS EndDate,
		CAST(0 AS VARBINARY(1)) AS [Days], 
		CAST(0 AS VARBINARY(4)) AS Times00_745, 
		CAST(0 AS VARBINARY(4)) AS Times08_1545, 
		CAST(0 AS VARBINARY(4)) AS Times16_2345
FROM	[Restaurant]
WHERE	[PublishPrivateDining] = 1
AND		RID NOT IN (SELECT ValueID FROM ValueLookupIDList WHERE LookupID = 36)
AND 	@OffersOn = 1
AND		@PrivateDiningAds = 1
AND		[Restaurant].RestStateID not in (4,11,15)
UNION ALL
SELECT 	DISTINCT PromoRests.RID, 
		[IconBoldText] AS OfferName, 
		CAST([Message] AS VARCHAR(1000)) AS [Description], 
		'-2' AS OfferOrder, 
		EventStartDate AS startDate,
		EventStartDate AS EndDate,
		CAST(0 AS VARBINARY(1)) AS [Days], 
		CAST(0 AS VARBINARY(4)) AS Times00_745, 
		CAST(0 AS VARBINARY(4)) AS Times08_1545, 
		CAST(0 AS VARBINARY(4)) AS Times16_2345
FROM 	[PromoPages]
INNER JOIN 	[HolidaySchedule] 
ON 			[PromoPages].[EventStartDate] = [HolidaySchedule].[HolidayDate]
INNER JOIN 	[PromoRests] 
ON 			[PromoPages].[PromoID]	= [PromoRests].[PromoID]
INNER JOIN 	[Restaurant] 
ON 			[PromoRests].[RID]		= [Restaurant].[RID]
inner join 	TimeZoneVW tz 
on			tz.TZID					= Restaurant.TZID
WHERE 	DATEDIFF(dd,EventStartDate,EventEndDate) = 1 
AND 	tz.CurrentLocalTime BETWEEN beginDate AND EndDate
AND 	PromoPages.Active = 1 
AND 	@OffersOn = 1
AND		[Restaurant].RestStateID not in (4,11,15)
UNION ALL
SELECT  DISTINCT pr.RID,
		[IconBoldText] AS [OfferName],
		'Get a free dessert in honor of the Top Chef Just Desserts Premiere! ' 
		 + CAST(pr.Message AS VARCHAR(1000)) 
		 + N' At least 1 entr&#233;e/person must be ordered for the free dessert (1 dessert per 2 people).' AS [Description],
		'9998' AS [OfferOrder],
		[EventStartDate]  AS StartDate,
		[EventStartDate]  AS EndDate,
		CAST(0 AS VARBINARY(1)) AS [Days], 
		CAST(0 AS VARBINARY(4)) AS [Times00_745], 
		CAST(0 AS VARBINARY(4)) AS [Times08_1545], 
		CAST(0 AS VARBINARY(4)) AS [Times16_2345]	
FROM 	[PromoPages]
INNER JOIN 	[PromoRests] pr
ON 			[PromoPages].[PromoID]	= pr.[PromoID]
INNER JOIN 	[Restaurant] 
ON 			pr.[RID]		= [Restaurant].[RID]
inner join 	TimeZoneVW tz 
on			tz.TZID					= Restaurant.TZID
WHERE 	[PromoPages].PromoID = 473 
AND 	tz.CurrentLocalTime BETWEEN BeginDate AND EndDate
AND 	PromoPages.Active = 1 
AND		[Restaurant].RestStateID not in (4,11,15)
UNION ALL
SELECT 	DISTINCT r.RID,
		'POP OFFER' AS [OfferName],
		'' AS [Description],
		'9999' AS [OfferOrder],
		'1/1/1900' AS [StartDate],
		'1/1/1900' AS [EndDate],
		CAST(0 AS VARBINARY(1)) AS [Days], 
		CAST(0 AS VARBINARY(4)) AS [Times00_745], 
		CAST(0 AS VARBINARY(4)) AS [Times08_1545], 
		CAST(0 AS VARBINARY(4)) AS [Times16_2345]	
FROM IncentiveVw i
INNER JOIN   [Restaurant]  r
ON  i.RID = r.RID AND r.RestStateID not in (4,11,15)
INNER JOIN 	TimeZoneVW tz 
ON	 tz.TZID	= r.TZID
LEFT OUTER JOIN ValueLookupIDList vl
ON   r.RID = vl.ValueID AND vl.LookupID = 51
WHERE  i.Active =1 
AND i.LastMinutePopThresholdTime IS NULL
AND  tz.CurrentLocalTime BETWEEN i.StartDate AND i.EndDate  
AND (ISNULL(vl.ValueID, 0) = 0)
GO


GRANT EXECUTE ON [dbo].[DNCachePromoOffers] TO ExecuteOnlyRole
GO
