if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoMigration_DeleteRestaurantMigrationReso_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoMigration_DeleteRestaurantMigrationReso_V2]
GO

--
-- Delete the migration reso task record (following successful execution).
-- Must delete a record to succeed
--

CREATE Procedure dbo.DNResoMigration_DeleteRestaurantMigrationReso_V2
 (
  @ReservationID int,
  @RestaurantMigrationQueueID int
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

DELETE  RestaurantMigrationReso
WHERE   ResID = @ReservationID

if (@@rowcount < 1)
begin
    -- this will fail the Migration transaction, but not the XML task
    raiserror('No RestaurantMigrationReso tasks were deleted for ResID %d', 16, 1, @ReservationID)
    return
end

-- Keep history of the migrated reso's in RestaurantMigratedReso
INSERT INTO RestaurantMigratedReso(ResID, RestaurantMigrationQueueID, CreatedDT)
VALUES (@ReservationID, @RestaurantMigrationQueueID, GETDATE())

if (@@rowcount < 1)
begin
    -- this will fail the Migration transaction, but not the XML task
    raiserror('No RestaurantMigratedReso tasks were inserted for ResID %d and QueueID %d', 16, 1, @ReservationID, @RestaurantMigrationQueueID)    
    return
end

GO

GRANT EXECUTE ON [DNResoMigration_DeleteRestaurantMigrationReso_V2] TO ExecuteOnlyRole

GO
