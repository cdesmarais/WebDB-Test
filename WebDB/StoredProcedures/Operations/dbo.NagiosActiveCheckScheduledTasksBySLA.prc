if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveCheckScheduledTasksBySLA]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveCheckScheduledTasksBySLA]
GO

CREATE PROCEDURE dbo.NagiosActiveCheckScheduledTasksBySLA
 @SLATypeID int = null,		--Current SLA's are Critical Systems, Support Hours, Call Center Hours, Business Hours, Periodic Tasks
 @IsSOX bit = null,				--Tells if the Task is under SOX scope or not.
 @HostName varchar(50) = null	--Name of the server the task is on.
 
As

SET NOCOUNT ON



--******************************************
--** General Comments:
--** This query retrieves the status and next runtime of ScheduledTasks and builds a result set for Nagios with 2 coulmns Status and 
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
--******************************************


declare @CurDate			datetime = getdate()
declare @status				int = 0
declare @tasks				nvarchar(max)=''			
declare @tasksdetailedmsg	nvarchar(max)=''

--Capture failed tasks if any
select	@status = 2,

		@tasks = case 
					when len(@tasks)> 0 then @tasks + ', ' + TaskName
					else 'Tasks failed: ' + TaskName
				 end,
		@tasksdetailedmsg = @tasksdetailedmsg + TaskName 

							+ ' Status:' + case when status = 2 then 'Failed ' else '' end
										 + case when expired = 1 then 'Expired ' else '' end
										 + case when OffSchedule = 1 then 'OffSchedule ' else '' end

							+ ' LastRun:' + ISNULL(CAST(LastRun AS varchar(20)),'') + CHAR(13) + CHAR(10)

from

(

select	t.status, 
		t.TaskName,
		t.UpdateDT as LastRun,
		(case	when StrictSchedule = 1  and abs(datediff(mi, OnSchedDate, UpdateDT)) > DurMaxMi then 1 -- did not run on schedule
			when expectedDate is null then 1
			when @CurDate > dateadd(mi, DurMaxMi, expectedDate) then 1 
			else 0 
		end) as Expired,   -- Determine if task is considered expired
		(case	when StrictSchedule = 1  and abs(datediff(mi, OnSchedDate, UpdateDT)) > DurMaxMi then 1
			else 0
		end) as OffSchedule -- Determine if the task didn't complete on expected schedule (slight variation upto tolerance time(DurMaxMi) is allowed)
from
	(
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
	where		st.active = 1
	and			(st.SLATypeID = @SLATypeID OR @SLATypeID is null)
	and			(st.IsSOX = @IsSOX OR @IsSOX is null)
	and			(st.HostName = @HostName OR @HostName is null)
	) t
) x

where	x.Status=2 
OR		x.Expired=1 
OR		x.OffSchedule=1

-- If no failed tasks, capture a list of all tasks
if (len(@tasks)<1) 
 begin
	select	@status = 0, -- Set status to Success
			@tasksdetailedmsg = @tasksdetailedmsg + TaskName + ' Status:Succeeded ' + ' LastRun:' + ISNULL(CAST(LastRun AS varchar(20)),'NULL') + CHAR(13) + CHAR(10)
	from	ScheduledTasks
	where	Active = 1
	and		(SLATypeID = @SLATypeID OR @SLATypeID is null)
	and		(IsSOX = @IsSOX OR @IsSOX is null)
	and		(HostName = @HostName OR @HostName is null)
	
	set		@tasks = 'Tasks checked: (' + CAST(@@ROWCOUNT AS VARCHAR) + ')'
 end


--Final Result
select	@status as [Status], 
		REPLACE(@tasks, ' ', '_') + CHAR(13) + CHAR(10) + REPLACE(@tasksdetailedmsg, ' ', '_') as ErrorMessage
		
GO

GRANT EXECUTE ON [NagiosActiveCheckScheduledTasksBySLA] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveCheckScheduledTasksBySLA] TO MonitorUser

GO
