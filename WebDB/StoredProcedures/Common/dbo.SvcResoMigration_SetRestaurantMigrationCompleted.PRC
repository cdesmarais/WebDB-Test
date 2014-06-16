if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_SetRestaurantMigrationCompleted]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_SetRestaurantMigrationCompleted]
GO

CREATE Procedure dbo.SvcResoMigration_SetRestaurantMigrationCompleted
 (
   @RestaurantMigrationQueueID   int
  ,@AllSucceeded                 int
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @RowsAffected int
declare @TaskStatus varchar(2)
set @TaskStatus = case when @AllSucceeded = 1 then 'CS' else 'CE' end

UPDATE  RestaurantMigrationQueue
set      TaskStatus = @TaskStatus
        ,NumAttempts = (NumAttempts + 1)
        ,LastAttemptDT = GETDATE()
WHERE   RestaurantMigrationQueueID = @RestaurantMigrationQueueID

select @RowsAffected = @@rowcount

if (@@rowcount < 1)
begin
    -- if this happens, we will fail the XML RestaurantMigration task
    raiserror('No restaurant migration queue records were updated for QueueID (%d)', 16, 1, @RestaurantMigrationQueueID)
end

GO

GRANT EXECUTE ON [SvcResoMigration_SetRestaurantMigrationCompleted] TO ExecuteOnlyRole

GO
