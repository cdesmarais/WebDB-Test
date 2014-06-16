if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_InsertIncentive2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_InsertIncentive2]
GO

CREATE procedure [dbo].[Incentive_InsertIncentive2]
(
@RID int, 
@StartDate datetime, 
@EndDate datetime, 
@IncentiveDay nvarchar(50),
@StartTime datetime,
@EndTime datetime, 
@IncHistID int,
@LastMinutePOPThresholdTime time
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
	LastMinutePOPThresholdTime
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
@LastMinutePOPThresholdTime
)

GO

GRANT EXECUTE ON [Incentive_InsertIncentive2] TO ExecuteOnlyRole

GO
