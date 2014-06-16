if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoMigration_UpdateRestaurantMigrationReso_GC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoMigration_UpdateRestaurantMigrationReso_GC]
GO

--
-- Update the migration reso task record (following successful execution).
-- For migration from ERB to GC only
--

CREATE Procedure dbo.DNResoMigration_UpdateRestaurantMigrationReso_GC
 (
  @RestaurantMigrationQueueID int,
  @MigratedResoIDs varchar(8000)
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
	
-- Check if RestaurantMigrationReso table primary key is not composite then exit
declare @PKColCount int
SELECT @PKColCount = Count(column_name)
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1
AND table_name = 'RestaurantMigrationReso'

if (@PKColCount = 1)
	return

declare @IDs table
(
	ResID int
)
	
declare @idx int       
declare @sID varchar(30)       

select @idx = 1       
    if len(@MigratedResoIDs)<1 or @MigratedResoIDs is null  return       

while @idx!= 0       
begin       
    set @idx = charindex(',',@MigratedResoIDs)       
    if @idx!=0       
        set @sID = left(@MigratedResoIDs,@idx - 1)       
    else       
        set @sID = @MigratedResoIDs       

    if(len(@sID)>0)  
    begin
		declare @nID int
		set @nID = CONVERT(int,@sID)
		if (not exists(select ResID from RestaurantMigrationReso where ResID = @nID and RestaurantMigrationQueueID = @RestaurantMigrationQueueID))
			insert into @IDs(ResID) values(@nID)
    end       

    set @MigratedResoIDs = right(@MigratedResoIDs,len(@MigratedResoIDs) - @idx)       
    if len(@MigratedResoIDs) = 0 break       
end   

if not exists (select * from @IDs)
	return

insert into RestaurantMigrationReso(ResID, RestaurantMigrationQueueID)
select	ResID
		,@RestaurantMigrationQueueID
from @IDs

declare @NumResos int
select			@NumResos = @@rowcount

if (@NumResos < 1)
begin
    -- this will fail the Migration transaction, but not the XML task
    raiserror('Failed to insert RestaurantMigrationReso tasks for QueueID %d', 16, 1, @RestaurantMigrationQueueID)    
    return
end



if (@NumResos > 0)
begin
	declare @TotNumResos int
	select		@TotNumResos = coalesce(NumResos, 0) 
	from		RestaurantMigrationQueue
	where		RestaurantMigrationQueueID	= @RestaurantMigrationQueueID
	
	set @TotNumResos = @TotNumResos + @NumResos
	
	update      RestaurantMigrationQueue   
	set         NumResos					= @TotNumResos
	where		RestaurantMigrationQueueID	= @RestaurantMigrationQueueID
end

GO

GRANT EXECUTE ON [DNResoMigration_UpdateRestaurantMigrationReso_GC] TO ExecuteOnlyRole

GO
