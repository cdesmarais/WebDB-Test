if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetScheduledTasks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)

drop procedure [dbo].[DNGetScheduledTasks]

GO

CREATE PROCEDURE dbo.DNGetScheduledTasks

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

select t.*, -- Retrieve necessary task data
	(case	when StrictSchedule = 1  and abs(datediff(mi, OnSchedDate, UpdateDT)) > DurMaxMi then 1 -- did not run on schedule
			when expectedDate is null then 1
			when @CurDate > dateadd(mi, DurMaxMi, expectedDate) then 1 
			else 0 
	end) Expired,   -- Determine if task is considered expired
	(case	when StrictSchedule = 1  and abs(datediff(mi, OnSchedDate, UpdateDT)) > DurMaxMi then 1
		else 0
	end) OffSchedule
from (
	select	st.scheduledtaskid,
			n.NagiosHost,
			isnull(n.NagiosTask, st.taskname) NagiosService,
			GroupData,
			GroupCount,
			StrictSchedule,
			(case when IsDBJob = 0 and st.runsucceeded = 1 then 0 
			      else 2 end) Status,
			coalesce(st.lastrun,st.startdate) UpdateDT, 
			st.taskname,
			st.hostname	COLLATE DATABASE_DEFAULT HostName,   
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
	inner join PeriodicityType pt on pt.PeriodicityTypeID = st.PeriodicityTypeID
	inner join NagiosTaskType n on st.NagiosTaskType = n.type and n.type != 0
	where	st.active=1
) t

order by GroupData, NagiosHost, NagiosService
GO

GRANT EXECUTE ON [DNGetScheduledTasks] TO ExecuteOnlyRole
GRANT EXECUTE ON [DNGetScheduledTasks] TO MonitorUser

GO
