
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNScheduledTasksUpdateRun]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNScheduledTasksUpdateRun]
GO

CREATE PROCEDURE dbo.DNScheduledTasksUpdateRun
  @TaskID int,
  @LastRunTime datetime,
  @RunSucceeded bit,
  @HostName nvarchar(50)
AS

  declare @message nvarchar(255)

  if exists(select ScheduledTaskID from ScheduledTasks where ScheduledTaskID = @TaskID)
BEGIN

  Update ScheduledTasks
  Set LastRun = @LastRunTime, HostName = @HostName, RunSucceeded = @RunSucceeded  
  Where ScheduledTaskID = @TaskID
 return;
END

-- print error message..
      set @message = 'no such taskID: ' + cast(@TaskID as nvarchar(10))
      Raiserror(@message,16,1)
      Return(1)

GO







GRANT EXECUTE ON [DNScheduledTasksUpdateRun] TO ExecuteOnlyRole

GO
