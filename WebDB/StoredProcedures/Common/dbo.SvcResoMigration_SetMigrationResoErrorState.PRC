if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_SetMigrationResoErrorState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_SetMigrationResoErrorState]
GO

CREATE Procedure dbo.SvcResoMigration_SetMigrationResoErrorState
 (
   @ReservationID   int
  ,@ErrorCode       int
  ,@ErrorMessage    varchar(500)
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @RowsAffected int

UPDATE  RestaurantMigrationReso
set      ErrorCode = @ErrorCode
        ,ErrorMessage = @ErrorMessage
        ,LastAttemptDT = GETDATE()
WHERE   ResID = @ReservationID

if (@@rowcount < 1)
begin
    -- if this happens, we will fail the XML RestaurantMigration task
    raiserror('No migration reso record entries was updated for @ReservationID (%d)', 16, 1, @ReservationID)
end

GO

GRANT EXECUTE ON [SvcResoMigration_SetMigrationResoErrorState] TO ExecuteOnlyRole

GO
