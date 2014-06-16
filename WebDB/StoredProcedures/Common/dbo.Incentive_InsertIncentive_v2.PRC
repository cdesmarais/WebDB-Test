if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_InsertIncentive_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_InsertIncentive_v2]
GO




CREATE procedure [dbo].[Incentive_InsertIncentive_v2]
(
@RID int, 
@StartDate datetime, 
@EndDate datetime, 
@IncentiveDay nvarchar(50),
@StartTime datetime,
@EndTime datetime, 
@IncHistID INT,
@LastMinutePopThresHoldTime time
)
As

--include createdate now in the query. 
Declare @IncentiveDayID int

SELECT @IncentiveDayID = DSchID from DaySchedule where DSchName = @IncentiveDay

INSERT INTO INCENTIVE
(
	RID, 
	IncentiveDay,
	Amount, 
	StartDate, 
	EndDate, 
	StartTime,
	EndTime, 
	CreateDate,
	ActiveIncHistID,
	LastMinutePopThresHoldTime 
)
VALUES
(
@RID,
@IncentiveDayID, 
1000, -- All DIP incentives are considered worth 1000 points
@StartDate, 
@EndDate, 
@StartTime,
@EndTime, 
getdate(),
@IncHistID,
@LastMinutePopThresHoldTime  
)

GO

GRANT EXECUTE ON [Incentive_InsertIncentive_v2] TO ExecuteOnlyRole

GO
