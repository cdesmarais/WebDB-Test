if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoMigration_UpdateRestaurantMigrationGuest_GC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoMigration_UpdateRestaurantMigrationGuest_GC]
GO

--
-- Update the migration reso task record (following successful execution).
-- For migration from ERB to GC only
--

CREATE Procedure dbo.DNResoMigration_UpdateRestaurantMigrationGuest_GC
 (
  @RestaurantMigrationQueueID int,
  @MigratedCustIDs varchar(8000)
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @MigrationTypeID int

select	@MigrationTypeID = RestaurantMigrationTypeID 
from	RestaurantMigrationQueue 
where	RestaurantMigrationQueueID = @RestaurantMigrationQueueID

if (@MigrationTypeID <> 2)		-- If not a migration from ERB
	return

declare @IDs table
(
	CustID int
)
	
declare @idx int       
declare @sID varchar(30)       

select @idx = 1       
    if len(@MigratedCustIDs)<1 or @MigratedCustIDs is null  return       

while @idx!= 0       
begin       
    set @idx = charindex(',',@MigratedCustIDs)       
    if @idx!=0       
        set @sID = left(@MigratedCustIDs,@idx - 1)       
    else       
        set @sID = @MigratedCustIDs       

    if(len(@sID)>0)  
    begin
		declare @nID int
		set @nID = CONVERT(int,@sID)
		if (not exists(select CustID from RestaurantMigrationGuest where CustID = @nID and RestaurantMigrationQueueID = @RestaurantMigrationQueueID))
			insert into @IDs(CustID) values(@nID)
    end       

    set @MigratedCustIDs = right(@MigratedCustIDs,len(@MigratedCustIDs) - @idx)       
    if len(@MigratedCustIDs) = 0 break       
end   

if not exists (select * from @IDs)
	return

insert into RestaurantMigrationGuest(CustID, RestaurantMigrationQueueID)
select	CustID
		,@RestaurantMigrationQueueID
from @IDs

if (@@rowcount < 1)
begin
    -- this will fail the Migration transaction, but not the XML task
    raiserror('Failed to insert RestaurantMigrationGuest tasks for QueueID %d', 16, 1, @RestaurantMigrationQueueID)    
    return
end

GO

GRANT EXECUTE ON [DNResoMigration_UpdateRestaurantMigrationGuest_GC] TO ExecuteOnlyRole

GO
