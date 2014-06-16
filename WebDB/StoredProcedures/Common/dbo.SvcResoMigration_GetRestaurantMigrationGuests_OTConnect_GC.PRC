if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_GetRestaurantMigrationGuests_OTConnect_GC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_GetRestaurantMigrationGuests_OTConnect_GC]
GO

CREATE Procedure dbo.SvcResoMigration_GetRestaurantMigrationGuests_OTConnect_GC
(
    @RestaurantMigrationQueueID   int
)
As
SET NOCOUNT ON
declare @DTNow datetime
declare @SourceRID int
declare @DestinationRID int
declare @RestaurantMigrationTypeID int
declare @ExclusionQueueID int
declare @ExclusionTaskStatus varchar
declare @PrevMigrationTypeID int
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

-- get the QueueID from which to exclude guests if migrating in the same direction
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
	    -- Delete any guests from RestaurantMigrationGuest that are a part of RestaurantMigratedGuest (last migration)
	    -- regardless of whether the last task was success (CS) or failure (CE)
	    -- CE check is just for extra security (RestaurantMigratedGuest will not contain any CustID in RestaurantMigrationGuest if Status is CE)	

		delete RestaurantMigrationGuest 
		from RestaurantMigrationGuest mnGuest 
		inner join RestaurantMigratedGuest mdGuest
		on mnGuest.CustID = mdGuest.CustID
		WHERE mdGuest.RestaurantMigrationQueueID = @ExclusionQueueID
	end
end

commit tran

select  c.CustID											CustID
	   --,c.Prefix											Prefix
	   ,c.FName												FName
	   ,c.LName												LName
	   --,GetCustomerPhones(c.CustID)						PhoneNumbers
	   ,c.Email												Email
	   ,coalesce(cn.Notes, '')								Notes 	      
       ,coalesce(c.CallerID, 0)                             CallerID
          
from        RestaurantMigrationGuest		mc

inner join  RestaurantMigrationQueue        q
on          q.RestaurantMigrationQueueID    = mc.RestaurantMigrationQueueID

inner join  Customer						c
on          c.CustID                        = mc.CustID

left outer join  CustomerNotes				cn
on          cn.CustomerID                   = mc.CustID

where       mc.RestaurantMigrationQueueID	= @RestaurantMigrationQueueID

GO

GRANT EXECUTE ON [SvcResoMigration_GetRestaurantMigrationGuests_OTConnect_GC] TO ExecuteOnlyRole

GO
