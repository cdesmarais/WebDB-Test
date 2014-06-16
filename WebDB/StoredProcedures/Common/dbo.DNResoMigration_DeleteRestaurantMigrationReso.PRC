if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoMigration_DeleteRestaurantMigrationReso]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoMigration_DeleteRestaurantMigrationReso]
GO

--
-- Delete the migration reso task record (following successful execution).
-- Must delete a record to succeed
--

CREATE Procedure dbo.DNResoMigration_DeleteRestaurantMigrationReso
 (
  @ReservationID int
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
end

GO

GRANT EXECUTE ON [DNResoMigration_DeleteRestaurantMigrationReso] TO ExecuteOnlyRole

GO
