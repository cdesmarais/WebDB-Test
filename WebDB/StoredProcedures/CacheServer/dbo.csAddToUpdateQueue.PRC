--$ create proc csAddToUpdateQueue
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csAddToUpdateQueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csAddToUpdateQueue]
go
create procedure dbo.csAddToUpdateQueue
(
  @RID int
)
as
	set nocount on
	set transaction isolation level read uncommitted

	exec dbo.DNAddRIDToCSQueue @RID
go

grant execute on dbo.csAddToUpdateQueue to ExecuteOnlyRole

GO
