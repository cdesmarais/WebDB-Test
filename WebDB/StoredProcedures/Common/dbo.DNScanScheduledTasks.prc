if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNScanScheduledTasks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNScanScheduledTasks]
GO

-- return list of scheduled tasks that have become due..
CREATE PROCEDURE dbo.DNScanScheduledTasks

@OTSInstanceName NVARCHAR(255)

As

SET NOCOUNT ON
 /*
 The "rm" periodicity is a relative month periodicity.  It designates
 that a task should run on a certain day of the month e.g. the first Monday
 of the month.
 Periodicity: 
			1 means 1st Sunday            8 means 2nd Sunday      15 means 3rd Sunday     23 means 4th Sunday  29 means LAST Sunday
            2 means 1st Monday            ....                    ....                    ....                    .....
            3 means 1st Tuesday
            4 means 1st Wednesday
            5 means 1st Thursday
            6 means 1st Friday
            7 means 1st Saturday          14 means 2nd Saturday   21 means 3rd Saturday   28 means 4th Saturday      35 means LAST Saturday
 */
-- scan scheduled task table and check if any are due..
--** If the current period is greater than the scheduled 
-- date + periodicty * periodicitytype
-- MMC Added an OTSInstanceName parameter for Console; only return tasks whose OTSInstance matches the input param
DECLARE @CurDT DATETIME
SET @CurDT = GETDATE()

select		st.scheduledtaskid,
			st.taskname, 
			st.LastRun 
from		scheduledtasks st 
inner join (
		select ScheduledTaskID,
		(case 
		when pt1.sqlparam ='mi' then dateadd(mi,((datediff(mi,st1.startdate,@CurDT)/st1.periodicity)*st1.periodicity),st1.startdate)
		when pt1.sqlparam ='hh' then dateadd(hh,((datediff(hh,st1.startdate,@CurDT)/st1.periodicity)*st1.periodicity),st1.startdate)
		when pt1.sqlparam ='dd' then dateadd(dd,((datediff(dd,st1.startdate,@CurDT)/st1.periodicity)*st1.periodicity),st1.startdate)
		when pt1.sqlparam ='wk' then dateadd(wk,((datediff(wk,st1.startdate,@CurDT)/st1.periodicity)*st1.periodicity),st1.startdate)
		when pt1.sqlparam ='mm' then dateadd(mm,((datediff(mm,st1.startdate,@CurDT)/st1.periodicity)*st1.periodicity),st1.startdate)
		when pt1.sqlparam ='rm' then dbo.fGetRelativeMonthDate(st1.periodicity, @CurDT) + dbo.fGetTimePart(st1.startdate)
	    end) AS NextSched
	    from ScheduledTasks st1
	    inner join PeriodicityType pt1
	    on pt1.PeriodicityTypeID = st1.PeriodicityTypeID) T
on		st.ScheduledTaskID = t.ScheduledTaskID	    
where	t.NextSched <= @CurDT
-- Make sure that the date to start the task has passed
and		@CurDt >= st.StartDate 
-- Make sure that the date to start the task has passed
and		@CurDt >= st.StartDate 
-- If the LastRun date is null, then the task may be newly inserted
-- so the StartDate is probably the NextSched date.  Compare NextSched
-- to StartDate - 1 so we are guaranteed to run
and 	(t.NextSched > st.LastRun OR ISNULL(st.LastRun,1) = 1)
and		st.active=1 
and		st.executetask=1
-- Only get tasks for the given OTSInstanceName
and		LOWER(st.OTSInstanceName) = LOWER(@OTSInstanceName) -- INPUT PARAM SHOULD ALREADY BE LOWER, BUT LET'S MAKE SURE

GO

GRANT EXECUTE ON [DNScanScheduledTasks] TO ExecuteOnlyRole

GO
