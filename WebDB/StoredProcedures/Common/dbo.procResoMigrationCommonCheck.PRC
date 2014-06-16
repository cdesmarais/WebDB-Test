if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procResoMigrationCommonCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procResoMigrationCommonCheck]
GO


CREATE Procedure dbo.procResoMigrationCommonCheck
(
  @SourceRID int,
  @DestinationRID int
)

As
SET NOCOUNT ON
set transaction isolation level read uncommitted


--========================================================================
-- VALIDATION
--========================================================================

--========================================================================
-- Validate: RestStateID for source and destination must be 
-- either 'closed temporarily' (5) 
-- or 'temp inactive' (7)
--========================================================================
declare @RestStateID int
declare @RState nvarchar(255)

select @RestStateID = RestStateID from Restaurant where RID = @SourceRID and RestStateID not in (5, 7)
if (@RestStateID is not null)
begin
    select @RState = RState from RestaurantState where RestStateID = @RestStateID
    raiserror('Migration blocked: illegal initial state (%s) for migration from RID %d', 16, 1, @RState, @SourceRID)
    return -1
end
if (@DestinationRID != @SourceRID)
begin
    select @RestStateID = RestStateID from Restaurant where RID = @DestinationRID and RestStateID not in (5, 7)
    if (@RestStateID is not null)
    begin
        select @RState = RState from RestaurantState where RestStateID = @RestStateID
        raiserror('Migration blocked: illegal initial state (%s) for migration to RID %d', 16, 1, @RState, @DestinationRID)
        return -1
    end
end

--========================================================================
-- Validate: BRUP queue is empty for source ERB
--========================================================================
select      top 1 * 
from        brupqueue           q 
left join   BRUPQueueProcessed  p
on          p.BRUPQueueID       = q.BRUPQueueID
and         p.Processed         = 1
where       p.BRUPQueueID       is null
and         q.RID               = @SourceRID

if (@@ROWCOUNT > 0)
begin
    -- there are unprocessed BRUP queue entries
    raiserror('Migration blocked: BRUP queue not empty for RID %d', 16, 1, @SourceRID)
    return -1
end

return 0

GO

GRANT EXECUTE ON [procResoMigrationCommonCheck] TO ExecuteOnlyRole

GO
