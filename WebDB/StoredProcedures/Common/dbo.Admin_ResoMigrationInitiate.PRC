if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ResoMigrationInitiate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ResoMigrationInitiate]
GO

--
-- This procedure is used to 
-- manually initiate the restaurant migration process from within Engineering.
-- 
CREATE Procedure dbo.Admin_ResoMigrationInitiate
 (
  @SourceRID int,
  @DestinationRID int,
  @DestinationRestaurantType char(1),
  @UserID nvarchar(100)

 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

-- check that the destination type is 'A' or 'E'
if (@DestinationRestaurantType not in ('A', 'E'))
begin
    raiserror('Initiation blocked: unsupported destination restaurant type (%s)', 16, 1, @DestinationRestaurantType)
    return -1
end

begin tran

declare @PreMigrationRestStateID int
set @PreMigrationRestStateID = 5 -- closed temporarily

--==========================================================
-- update restaurant type, restaurant state, version number
--==========================================================

-- put source RID in closed temporarily state
update  Restaurant
set     RestStateID         = @PreMigrationRestStateID
where   RID                 = @SourceRID

if (@DestinationRestaurantType = 'E')
begin
    -- put destination RID in closed temporarily state, and set type
    update  Restaurant
    set     RestaurantType      = 'E' 
           ,Allotment           = 0
           ,RestStateID         = @PreMigrationRestStateID
    where   RID                 = @DestinationRID
end

else if (@DestinationRestaurantType = 'A')
begin
    -- put destination RID in closed temporarily state, and set type
    update  Restaurant
    set     RestaurantType      = 'A' 
           ,Allotment           = 1
           ,RestStateID         = @PreMigrationRestStateID
    where   RID                 = @DestinationRID

    -- for console destination, assign a distinct non-conflict version number
    declare @ConsoleRestaurantVersion varchar(50)
    set     @ConsoleRestaurantVersion = '1.0.0.1000'

    update  ERBRestaurant 
    set     ERBVersion          = @ConsoleRestaurantVersion 
    where   RID                 = @DestinationRID
end

--==========================================================
-- log RestState changes
--==========================================================
exec Admin_AuditRestStatusChg @SourceRID, @UserID, @PreMigrationRestStateID
exec Admin_AuditRestStatusChg @DestinationRID, @UserID, @PreMigrationRestStateID

commit tran


GO

GRANT EXECUTE ON [Admin_ResoMigrationInitiate] TO ExecuteOnlyRole

GO
