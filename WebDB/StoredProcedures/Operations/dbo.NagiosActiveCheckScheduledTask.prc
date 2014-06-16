if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveCheckScheduledTask]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveCheckScheduledTask]
GO

CREATE PROCEDURE dbo.NagiosActiveCheckScheduledTask
 @ScheduledTaskID int
As

SET NOCOUNT ON



--******************************************
--** General Comments:
--** This query retrieves the status and next runtime of ScheduledTasks
--**
--** Things you will notice:
--**	OnSchedDate -- This represents the expected schedule date, based on the scheduledTasks.StartTime
--**	ExpectedDate -- The date the job is expected to run next. Based on the last run date (add the periodicty to the last run)
--**
--** Expressions used: 
--**	coalesce(st.lastrun,st.startdate)  -- Represents the last run of the task
--**														st.lastrun  - Use the last runDT of the task in ScheduleTasks (if it exists)
--**														st.startdate  - Else use the last runDT of the task in ScheduleTasks 
--**
--** NOTE: Must contain the following: GroupData	NagiosHost	NagiosService	Expired	Status	UpdateDT 
--**
--******************************************
declare @CurDate datetime
set @CurDate = getdate()

declare @status int
declare @expired int
declare @offschedule int
declare @TaskName nvarchar(200)
declare @LastRun nvarchar(200)

select	@status = t.status, 
		@TaskName = t.TaskName,
		@LastRun = t.UpdateDT,
		@expired = (case	when StrictSchedule = 1  and abs(datediff(mi, OnSchedDate, UpdateDT)) > DurMaxMi then 1 -- did not run on schedule
			when expectedDate is null then 1
			when @CurDate > dateadd(mi, DurMaxMi, expectedDate) then 1 
			else 0 
		end),   -- Determine if task is considered expired
		@offschedule = (case	when StrictSchedule = 1  and abs(datediff(mi, OnSchedDate, UpdateDT)) > DurMaxMi then 1
			else 0
		end)
from (
	select	st.scheduledtaskid,
			StrictSchedule,
			(case 
			      when st.runsucceeded = 1 then 0 
			      else 2 end) Status,
			coalesce(st.lastrun,st.startdate) UpdateDT, 
			st.taskname,
			st.hostname, 
			st.runsucceeded, 
			pt.sqlparam,
			IsNull(st.OptMaxDurMi, DefaultMaxDurMi) DurMaxMi,
			-- Converts the time to the exact expected time
			(case	when pt.sqlparam ='mi' then dateadd(mi,periodicity, coalesce(st.lastrun,st.startdate))
				when pt.sqlparam ='hh' then dateadd(hh,periodicity, coalesce(st.lastrun,st.startdate))	
				when pt.sqlparam ='dd' then dateadd(dd,periodicity, coalesce(st.lastrun,st.startdate))
				when pt.sqlparam ='wk' then dateadd(wk,periodicity, coalesce(st.lastrun,st.startdate))
				when pt.sqlparam ='mm' then dateadd(mm,periodicity, coalesce(st.lastrun,st.startdate))
				when pt.sqlparam ='rm' then 
					(case when (dbo.fGetRelativeMonthDate(st.periodicity,@CurDate) + dbo.fGetTimePart(st.startdate)) < st.lastrun
					 then dateadd(mm,1,(dbo.fGetRelativeMonthDate(st.periodicity,@CurDate))) + dbo.fGetTimePart(st.startdate)
					 else dbo.fGetRelativeMonthDate(st.periodicity,@CurDate) + dbo.fGetTimePart(st.startdate)
					 end)
 		  	end)  ExpectedDate,
 		  	-- Computes the scheduled date based on the taks StartDate
			(case	when pt.sqlparam ='mi' then dateadd(mi, datediff(mi,st.startdate, coalesce(st.lastrun,st.startdate)), st.startdate)
				when pt.sqlparam ='hh' then dateadd(hh, datediff(hh,st.startdate, coalesce(st.lastrun,st.startdate)), st.startdate)
				when pt.sqlparam ='dd' then dateadd(dd, datediff(dd,st.startdate, coalesce(st.lastrun,st.startdate)), st.startdate)
				when pt.sqlparam ='wk' then dateadd(wk, datediff(wk,st.startdate, coalesce(st.lastrun,st.startdate)), st.startdate)
				when pt.sqlparam ='mm' then dateadd(mm, datediff(mm,st.startdate, coalesce(st.lastrun,st.startdate)), st.startdate)
				when pt.sqlparam ='rm' then
					(case when (dbo.fGetRelativeMonthDate(st.periodicity,@CurDate) + dbo.fGetTimePart(st.startdate)) < st.lastrun
					 then dateadd(mm,1,(dbo.fGetRelativeMonthDate(st.periodicity,@CurDate))) + dbo.fGetTimePart(st.startdate)
					 else dbo.fGetRelativeMonthDate(st.periodicity,@CurDate) + dbo.fGetTimePart(st.startdate)
					 end)				
 		  	end)  OnSchedDate 		  	
	from	scheduledtasks st 
	inner join	PeriodicityType pt 
	on			pt.PeriodicityTypeID = st.PeriodicityTypeID
	where		st.ScheduledTaskID = @ScheduledTaskID
	and			st.active=1
) t


declare @message nvarchar(200)

--** Output Status and message
--** Note Currently a bug in nagios; success must only be 0 (no message)
if (@status = 2 or @expired = 1 or @offschedule =1)
begin
	 set @message = 'Task  FAILED'
	 set @status = 2 
end
else if (@status is null) set @message = 'Task Not found  ScheduledTaskID:' + convert(varchar(20), @ScheduledTaskID)
else set @message = ''

if (@status is not null) 
	set @message = @TaskName + ':  LastRun ' + @LastRun + '  Status: '+ @message 
					+ (case when @expired = 1 then '  Expired ' else '' end)
					+ (case when @offschedule = 1 then '  Offschedule ' else '' end)


select  @status as Status,
		(case when @status = 0 then '' else replace(@message, ' ', '_') end) as ErrorMessage
GO

GRANT EXECUTE ON [NagiosActiveCheckScheduledTask] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveCheckScheduledTask] TO MonitorUser

GO
