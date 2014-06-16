if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ResoMigrationEnqueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ResoMigrationEnqueue]
GO


CREATE Procedure dbo.Admin_ResoMigrationEnqueue
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
-- VALIDATION
--========================================================================

declare @rc int
-- common check for RIDs TempInactive, BRUP Queue empty
exec @rc = procResoMigrationCommonCheck @SourceRID, @DestinationRID
if (@rc != 0)
    return

--========================================================================
-- Validate: any previously queued migrations 
-- involving either the source or destination RID
-- must have been completed successfully
-- NOTE: It is possible that the SourceRID was previously part of a migration where it was the destination and vice versa
--========================================================================
declare     @ConflictingRestaurantMigrationQueueID int
declare     @ConflictingTaskStatus varchar(2)
declare @ConflictingSourceRID int
declare @ConflictingDestinationRID int

select       top 1 @ConflictingRestaurantMigrationQueueID    = RestaurantMigrationQueueID
            ,@ConflictingTaskStatus                         = TaskStatus
            ,@ConflictingSourceRID          = SourceRID 
            ,@ConflictingDestinationRID     = DestinationRID
from        RestaurantMigrationQueue
where       TaskStatus                                      != 'CS'    
and         (SourceRID                                      in (@SourceRID, @DestinationRID)
or           DestinationRID                                 in (@SourceRID, @DestinationRID))

if (@ConflictingRestaurantMigrationQueueID is not null)
begin
    -- there are conflicting already queued migrations
    raiserror('Migration blocked: Conflicting migration task in state %s exists from RID %d to RID %d', 16, 1,
               @ConflictingTaskStatus ,@ConflictingSourceRID, @ConflictingDestinationRID)
    return
end

--========================================================================
-- Validate: success
--========================================================================
insert RestaurantMigrationQueue
(
     SourceRID
    ,DestinationRID
    ,DueDT
    ,ForceFit
    ,TaskStatus
    ,NumAttempts
)
values
(
     @SourceRID
    ,@DestinationRID
    ,@DueDT
    ,@ForceFit
    ,'R'  -- ready to run
    ,0  -- never attempted
)

GO

GRANT EXECUTE ON [Admin_ResoMigrationEnqueue] TO ExecuteOnlyRole

GO
