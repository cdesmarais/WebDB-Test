if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateSchedTaskLastRunTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateSchedTaskLastRunTime]
GO

-- return list of scheduled tasks that have become due..
CREATE PROCEDURE dbo.DNUpdateSchedTaskLastRunTime
(
		@theScheduledTaskID int,
		@theOutcome int
)
As

SET NOCOUNT ON

-- Update scheduled task last run time and outcome..

update scheduledtasks 
set lastrun=cast(CONVERT(CHAR(10),getdate(),101) as datetime)+cast(CONVERT(CHAR(12),lastrun,108) as datetime),
runsucceeded=@theOutcome 
where scheduledtaskid=@theScheduledTaskID



GO

GRANT EXECUTE ON [DNUpdateSchedTaskLastRunTime] TO ExecuteOnlyRole

GO
