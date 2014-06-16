

--This proc inserts POP data.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_InsertIncentive_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_InsertIncentive_v2]
go

create procedure [dbo].[Draft_Incentive_InsertIncentive_v2]
(
    @RID int 
    ,@StartDate datetime 
    ,@EndDate datetime 
    ,@IncentiveDay nvarchar(50)
    ,@StartTime datetime
    ,@EndTime datetime
    ,@LastMinutePopThresHoldTime time
)
as

    --include createdate now in the query. 
    declare @IncentiveDayID int

    --Select incentive day
    select 
        @IncentiveDayID = DSchID 
    from 
        DaySchedule 
    where 
        DSchName = @IncentiveDay

    -- insert information
    insert into DraftIncentive
    (
        RID 
        ,IncentiveDay
        ,Amount 
        ,StartDate 
        ,EndDate 
        ,StartTime
        ,EndTime 
        ,CreateDate
        ,LastMinutePopThresHoldTime
    )
    values
    (
        @RID
        ,@IncentiveDayID 
        ,1000 -- All DIP incentives are considered worth 1000 points
        ,@StartDate 
        ,@EndDate 
        ,@StartTime
        ,@EndTime 
        ,getdate()
        ,@LastMinutePopThresHoldTime
    )

go

grant execute on [Draft_Incentive_InsertIncentive_v2] to ExecuteOnlyRole

go

