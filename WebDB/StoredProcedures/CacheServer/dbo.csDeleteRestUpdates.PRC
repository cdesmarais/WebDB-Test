--$ create proc csDeleteRestUpdates
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csDeleteRestUpdates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csDeleteRestUpdates]
GO

CREATE   Procedure dbo.csDeleteRestUpdates
(
	@CSRestUpdateMaxProcessedID int
)
As

set transaction isolation level read uncommitted
SET NOCOUNT ON

-- @CSRestUpdateMaxProcessedID is the max id of any update processed by the cache server
-- call stored proc to delete all updates with id <= @CSRestUpdateMaxProcessedID
Exec DNDeleteCSRestaurantUpdates @CSRestUpdateMaxProcessedID
GO

GRANT EXECUTE ON [csDeleteRestUpdates] TO ExecuteOnlyRole
GO
