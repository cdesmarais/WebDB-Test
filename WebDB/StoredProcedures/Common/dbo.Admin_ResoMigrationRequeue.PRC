if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ResoMigrationRequeue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ResoMigrationRequeue]
GO


CREATE Procedure dbo.Admin_ResoMigrationRequeue
 (
  @SourceRID int,
  @DestinationRID int,
  @DueDT datetime,
  @ForceFit bit
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

--========================================================================
-- look for existing migration task (will have maximum ID of all matching tasks)
--========================================================================
declare     @RestaurantMigrationQueueID int
declare     @TaskStatus varchar(2)
select       top 1 @RestaurantMigrationQueueID = RestaurantMigrationQueueID
            ,@TaskStatus = TaskStatus
from        RestaurantMigrationQueue
where       SourceRID                   = @SourceRID
and         DestinationRID              = @DestinationRID
order by    RestaurantMigrationQueueID  desc


--========================================================================
-- VALIDATION
--========================================================================

declare @rc int
-- common check for RIDs TempInactive, BRUP Queue empty
exec @rc = procResoMigrationCommonCheck @SourceRID, @DestinationRID
if (@rc != 0)
    return
    
    
if (@RestaurantMigrationQueueID is null)
begin
    -- task not found
    raiserror ('Requeue blocked: Restaurant Migration Task from RID %d to RID %d Does Not Exist', 16, 1,
                @SourceRID, @DestinationRID)
    return
end
if (@TaskStatus not in ('CE', 'R'))
begin
    -- task not completed with errors or ready 
    -- (requeueing a ready task allows us to modify the due date or other task params)
    raiserror ('Requeue blocked: Restaurant Migration Task from RID %d to RID %d is in state %s', 16, 1,
                @SourceRID, @DestinationRID, @TaskStatus)
    return
end


--========================================================================
-- requeue step
--========================================================================
update  RestaurantMigrationQueue
set     DueDT                       = @DueDT,
        ForceFit                    = @ForceFit,
        TaskStatus                  = 'R'          -- ready to run
where   RestaurantMigrationQueueID  = @RestaurantMigrationQueueID
and     TaskStatus                  in ('CE', 'R') 

if (@@ROWCOUNT = 0)
begin
    select @TaskStatus = TaskStatus from RestaurantMigrationQueue where RestaurantMigrationQueueID = @RestaurantMigrationQueueID
    raiserror ('Requeue failed: Active Restaurant Migration Task from RID %d to RID %d has moved to state %s', 16, 1,
                @SourceRID, @DestinationRID, @TaskStatus)
    return
end

GO

GRANT EXECUTE ON [Admin_ResoMigrationRequeue] TO ExecuteOnlyRole

GO
