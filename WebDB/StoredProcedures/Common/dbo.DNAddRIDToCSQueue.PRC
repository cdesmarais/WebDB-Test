--$ create proc DNAddRIDToCSQueue
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAddRIDToCSQueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAddRIDToCSQueue]
go
create procedure dbo.DNAddRIDToCSQueue
(
  @RID int
)
as
	set nocount on
	set transaction isolation level read uncommitted

    declare @CacheServerID int

    select @CacheServerID = csg.CacheServerID 
    from       CacheServerERBGroup csg
    inner join ERBRestaurant       er
    on         er.CacheServerERBGroupID = csg.CacheServerERBGroupID 
	where      er.RID = @RID

	if @CacheServerID is not null
	begin

	if not exists ( select 1 from CacheServerUpdateQueue 
					where CacheServerID = @CacheServerID
					and RID = @RID
					and Action = 'A' )		
		insert into CacheServerUpdateQueue ( CacheServerID, RID, Action )
		values ( @CacheServerID, @RID, 'A' ) -- add to queue
	end
go

grant execute on dbo.DNAddRIDToCSQueue to ExecuteOnlyRole

GO
