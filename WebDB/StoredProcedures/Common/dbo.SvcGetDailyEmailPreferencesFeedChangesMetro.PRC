if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetDailyEmailPreferencesFeedChangesMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcGetDailyEmailPreferencesFeedChangesMetro]
GO


CREATE PROCEDURE dbo.SvcGetDailyEmailPreferencesFeedChangesMetro
(
	@StartDateUTC   datetime,
	@EndDateUTC	datetime
)
as

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @StartTimeUTC datetime, @EndTimeUTC datetime, @UTCMIDiff int


--Get the offset for the UTC comparisons
select	top 1 @UTCMIDiff = (ServerOffsetMI * -1)
from	TimezoneVW

set @StartTimeUTC = dateadd(MI,@UTCMIDiff,@StartDateUTC)
set @EndTimeUTC = dateadd(MI,@UTCMIDiff,@EndDateUTC)

select	
		u.CustID UserID,
		u.MetroAreaID,		
		CAST(u.SpotLight AS INT) Spotlight,
		CAST(u.Insider AS INT) Insider,
		CAST(u.DinersChoice AS INT) DinersChoice,
		CAST(u.NewHot AS INT) NewHot,
		CAST(u.RestaurantWeek AS INT) RestaurantWeek,
		CAST(u.Promotional AS INT) Promotional,	
		CAST(u.Product AS INT) Product
		FROM UserOptIn u
	    INNER JOIN Customer cu
	    on u.CustID = cu.CustID	      	        
		WHERE cu.ConsumerType in (1, 4, 5, 8)   -- 1:Normal User, 4:Gold, 5:Manual Gold, 8:Anonymous
		AND u.MetroAreaID is not null 
		AND u.UpdatedDtUTC between @StartTimeUTC and @EndTimeUTC		
		AND (cu.Active = 1 OR cu.UpdatedUTC between @StartTimeUTC and @EndTimeUTC)
union all
select
		(-1)* u.CallerID UserID,
		u.MetroAreaID,
		CAST(u.SpotLight AS INT) Spotlight,
		CAST(u.Insider AS INT) Insider,
		CAST(u.DinersChoice AS INT) DinersChoice,
		CAST(u.NewHot AS INT) NewHot,
		CAST(u.RestaurantWeek AS INT) RestaurantWeek,
		CAST(u.Promotional AS INT) Promotional,		
		CAST(u.Product AS INT) Product
		FROM UserOptIn u
		inner join Caller ca
		on u.CallerID = ca.CallerID
		WHERE ca.PositionID <> 2   -- PostionID 2: Concierge       
		AND u.MetroAreaID is not null 
		AND u.UpdatedDtUTC between @StartTimeUTC and @EndTimeUTC
		AND (ca.CallerStatusID = 1 OR ca.UpdatedUTC between @StartTimeUTC and @EndTimeUTC)
GO			
		

GRANT EXECUTE ON [SvcGetDailyEmailPreferencesFeedChangesMetro] TO ExecuteOnlyRole
GO

