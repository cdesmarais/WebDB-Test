if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetDailyEmailPreferencesFeedChangesMetro_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcGetDailyEmailPreferencesFeedChangesMetro_v2]
GO


CREATE PROCEDURE dbo.SvcGetDailyEmailPreferencesFeedChangesMetro_v2
(
	@StartDateUTC   datetime,
	@EndDateUTC	DATETIME, 
	@MaxUpdatedUTC datetime out
)
as

SET NOCOUNT ON
set transaction isolation level read uncommitted

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
		AND u.UpdatedDtUTC between @StartDateUTC and @EndDateUTC		
		AND cu.Active = 1
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
		AND u.UpdatedDtUTC between @StartDateUTC and @EndDateUTC
		AND ca.CallerStatusID = 1


DECLARE @MaxCustUpdatedUTC DATETIME, @MaxCallerUpdatedUTC datetime

SELECT @MaxCustUpdatedUTC =	CASE WHEN MAX(cu.UpdatedUTC) >= MAX(u.UpdatedDtUTC) THEN MAX(cu.UpdatedUTC) ELSE MAX(u.UpdatedDtUTC) END 
		FROM UserOptIn u
		INNER JOIN Customer cu
		on u.CustID = cu.CustID	      	        
		WHERE cu.ConsumerType in (1, 4 , 5, 8)   -- 1:Normal User, 4:Gold, 5:Manual Gold, 8:Anonymous
		AND u.MetroAreaID is not null 
		AND u.UpdatedDtUTC between @StartDateUTC and @EndDateUTC		
		AND cu.Active = 1


SELECT @MaxCallerUpdatedUTC = CASE WHEN MAX(ca.UpdatedUTC) >= MAX(u.UpdatedDtUTC) THEN MAX(ca.UpdatedUTC) ELSE MAX(u.UpdatedDtUTC) END 	
		FROM UserOptIn u
		inner join Caller ca
		on u.CallerID = ca.CallerID
		WHERE ca.PositionID <> 2   -- PostionID 2: Concierge       
		AND u.MetroAreaID is not null 
		AND u.UpdatedDtUTC between @StartDateUTC and @EndDateUTC
		AND ca.CallerStatusID = 1
			
SELECT @MaxUpdatedUTC = CASE WHEN @MaxCustUpdatedUTC >= @MaxCallerUpdatedUTC THEN @MaxCustUpdatedUTC ELSE @MaxCallerUpdatedUTC END	

GO			
		

GRANT EXECUTE ON [SvcGetDailyEmailPreferencesFeedChangesMetro_v2] TO ExecuteOnlyRole
GO

