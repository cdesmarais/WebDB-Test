if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoMigration_DeleteRestaurantMigrationGuest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoMigration_DeleteRestaurantMigrationGuest]
GO

--
-- Delete the migration reso task record (following successful execution).
-- Must delete a record to succeed
--

CREATE Procedure dbo.DNResoMigration_DeleteRestaurantMigrationGuest
 (
  @RestaurantMigrationQueueID int,
  @MigratedGuestIDs varchar(8000)
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @IDs table
(
	GuestID int
)
	
declare @idx int       
declare @sID varchar(30)       

select @idx = 1       
    if len(@MigratedGuestIDs)<1 or @MigratedGuestIDs is null  return       

while @idx!= 0       
begin       
    set @idx = charindex(',',@MigratedGuestIDs)       
    if @idx!=0       
        set @sID = left(@MigratedGuestIDs,@idx - 1)       
    else       
        set @sID = @MigratedGuestIDs       

    if(len(@sID)>0)  
    begin
		declare @nID int
		set @nID = CONVERT(int,@sID)
		if (exists(select CustID from RestaurantMigrationGuest where CustID = @nID and RestaurantMigrationQueueID = @RestaurantMigrationQueueID))
			insert into @IDs(GuestID) values(@nID)
    end       

    set @MigratedGuestIDs = right(@MigratedGuestIDs,len(@MigratedGuestIDs) - @idx)       
    if len(@MigratedGuestIDs) = 0 break       
end   

if not exists (select * from @IDs)
	return
	
-- Keep history of the migrated reso's in RestaurantMigratedReso
insert into RestaurantMigratedGuest(CustID, RestaurantMigrationQueueID, CreatedDT)
select	GuestID
		,@RestaurantMigrationQueueID
		, GETDATE()
from @IDs

if (@@rowcount < 1)
begin
    -- this will fail the Migration transaction, but not the XML task
    raiserror('Failed to insert RestaurantMigratedGuest tasks for QueueID %d', 16, 1, @RestaurantMigrationQueueID)    
    return
end
	
delete  RestaurantMigrationGuest
where   CustID in (select GuestID from @IDs)

if (@@rowcount < 1)
begin
    -- this will fail the Migration transaction, but not the XML task
    raiserror('No RestaurantMigrationGuest tasks were deleted for for QueueID %d', 16, 1, @RestaurantMigrationQueueID)
end

GO

GRANT EXECUTE ON [DNResoMigration_DeleteRestaurantMigrationGuest] TO ExecuteOnlyRole

GO
