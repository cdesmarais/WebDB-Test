if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_GetRestaurantMigrationResos_OTConnect_GC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_GetRestaurantMigrationResos_OTConnect_GC]
GO

CREATE Procedure dbo.SvcResoMigration_GetRestaurantMigrationResos_OTConnect_GC
(
    @RestaurantMigrationQueueID   int
)
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @DTNow datetime
declare @NumUnqueuedResos int
declare @SourceRID int
declare @DestinationRID int
declare @RestaurantMigrationTypeID int
declare @ExclusionQueueID int
declare @ExclusionTaskStatus varchar
declare @PrevMigrationTypeID int
declare @NumPrevMigratedResos int
select @DTNow = GETDATE()

if (not exists (select RestaurantMigrationQueueID from RestaurantMigrationQueue where RestaurantMigrationQueueID = @RestaurantMigrationQueueID))
begin
    -- if this happens, we will fail the XML RestaurantMigration task
    raiserror('The specified migration task (%d) does not exist', 16, 1, @RestaurantMigrationQueueID)
end


begin tran

-- get the SourceRID, DestinationRID and MigrationType of the migration from RestaurantMigrationQueueID
SELECT  @SourceRID = SourceRID,
	@DestinationRID = DestinationRID,
        @RestaurantMigrationTypeID = RestaurantMigrationTypeID
        
FROM RestaurantMigrationQueue
WHERE RestaurantMigrationQueueID = @RestaurantMigrationQueueID

-- get the QueueID from which to exclude reservations if migrating in the same direction
-- (going from same SourceRID to same DestinationRID with the same RestaurantMigrationTypeID - indicates same direction)
SELECT top 1 @ExclusionQueueID    = RestaurantMigrationQueueID
            ,@ExclusionTaskStatus = TaskStatus
            ,@PrevMigrationTypeID = RestaurantMigrationTypeID
            
from        RestaurantMigrationQueue
WHERE         SourceRID = @SourceRID
and DestinationRID = @DestinationRID
-- exclude current task whose status will be 'P' - In progress
and TaskStatus = 'CS' or TaskStatus = 'CE'
-- very important (ensures that most recent migration prior to the current migration is picked by select top 1)
ORDER BY DueDT DESC

if (@PrevMigrationTypeID is not null)
-- there has been prior migration from the same source rid to destination rid
begin
	if (@PrevMigrationTypeID = @RestaurantMigrationTypeID)
	-- the prior migration has been in the same direction
	begin 
	    -- Delete any resos from RestaurantMigrationReso that are a part of RestaurantMigratedReso (last migration)
	    -- regardless of whether the last task was success (CS) or failure (CE)
	    -- CE check is just for extra security (RestaurantMigratedReso will not contain any ResID in RestaurantMigrationReso if Status is CE)	

		delete RestaurantMigrationReso 
		from RestaurantMigrationReso mnReso 
		inner join RestaurantMigratedReso mdReso
		on mnReso.ResID = mdReso.ResID
		WHERE mdReso.RestaurantMigrationQueueID = @ExclusionQueueID
		
		select @NumPrevMigratedResos = @@ROWCOUNT
		if (@NumPrevMigratedResos > 0)
		begin
		   update  RestaurantMigrationQueue
  		   set     NumResos = NumResos - @NumPrevMigratedResos
   		   where   RestaurantMigrationQueueID = @RestaurantMigrationQueueID
		end
	end
end

-- If rowcount > 0 then update total resos in Master Task
select		@NumUnqueuedResos				= count(ResID) 
from		RestaurantMigrationReso 
where		RestaurantMigrationQueueID		= @RestaurantMigrationQueueID

if (@NumUnqueuedResos > 0)
begin
    update  RestaurantMigrationQueue
    set     NumResos = NumResos - @NumUnqueuedResos
    where   RestaurantMigrationQueueID = @RestaurantMigrationQueueID
end

commit tran

select  r.RID                                             RID
	   ,r.ResID												ResID
	   ,r.ConfNumber										ConfNumber
	   ,r.TimeArrived										TimeArrived
	   ,r.CustID                                            CustID
	   ,r.TimeCompleted										TimeCompleted
	   ,r.DateMade											DateMade
	   ,r.Notes                                             Notes 	      
       ,r.PartySize                                         PartySize
       ,r.TimeSeated                                        TimeSeated 
       ,case	when r.RStateID=1 then 'NotConfirmed'
				when r.RStateID=3 then 'Cancelled'				
				when r.RStateID=4 then 'NoShow'				
				when r.RStateID=5 then 'AssumedSeated'
				when r.RStateID=6 then 'AssumedDone'
				when r.RStateID=7 then 'Seated'
				when r.RStateID=8 then 'Cancelled'
				when r.RStateID=9 then 'Cancelled'	
				when r.RStateID=10 then 'NoShow'			
				else rs.RStateName end                      ResState
       --,r.Codes                                             Codes 
       ,r.ResTime                                           ResTime   
       ,r.ShiftDate                                         ShiftDate            
       --,r.TurnTime                                          TurnTime 
       --,r.Scheduled                                         Scheduled        
       ,coalesce(r.CallerID, 0)                             CallerID
          
from        RestaurantMigrationReso         m

inner join  RestaurantMigrationQueue        q
on          q.RestaurantMigrationQueueID    = m.RestaurantMigrationQueueID

inner join  Reservation                     r
on          r.ResID                         = m.ResID

inner join ReservationState					rs
on			rs.RStateID						= r.RStateID

where       m.RestaurantMigrationQueueID    = @RestaurantMigrationQueueID
and         q.TaskStatus                    = 'P'   -- defensive programming; restrict to in-progress tasks
GO

GRANT EXECUTE ON [SvcResoMigration_GetRestaurantMigrationResos_OTConnect_GC] TO ExecuteOnlyRole

GO
