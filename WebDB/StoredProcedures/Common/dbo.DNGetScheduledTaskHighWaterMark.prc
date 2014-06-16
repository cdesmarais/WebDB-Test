

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetScheduledTaskHighWaterMark]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetScheduledTaskHighWaterMark]
go

create procedure dbo.DNGetScheduledTaskHighWaterMark
(
	@ScheduledTaskID int
)
as

set nocount on

	/*
		Gets the Scheduled Task High Water Mark. i.e.
								When the task is success - the HWM = LastRun
								When the task fails      - the HWM = StartDate
		Content owned by India Team. Please inform asaxena@opentable.com, if changing.
	*/

	select
		case 
			when RunSucceeded = 1 then dbo.fTimeConvert(LastRun, 4, 15) -- TZID = 4 (PST), TZID = 15 (GMT\UTC)
			else null
		end as HighWaterMarkUTC			
	from
		ScheduledTasks
	where
		ScheduledTaskID = @ScheduledTaskID
go

grant execute on [DNGetScheduledTaskHighWaterMark] TO ExecuteOnlyRole

go

