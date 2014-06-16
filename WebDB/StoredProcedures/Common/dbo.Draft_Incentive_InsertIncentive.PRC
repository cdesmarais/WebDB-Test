

--This proc inserts POP data.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_InsertIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_InsertIncentive]
go

create procedure [dbo].[Draft_Incentive_InsertIncentive]
(
    @RID int 
    ,@StartDate datetime 
    ,@EndDate datetime 
    ,@IncentiveDay nvarchar(50)
    ,@StartTime datetime
    ,@EndTime datetime 
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
    )

go

grant execute on [Draft_Incentive_InsertIncentive] to ExecuteOnlyRole

go

