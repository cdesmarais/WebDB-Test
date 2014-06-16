--$ create proc dbgCacheServerDown
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgCacheServerDown]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgCacheServerDown]
go
create proc dbgCacheServerDown
(
	  @CacheServerID int
)
as
	update CacheServer
	set DownDT_UTC = getutcdate()
	where CacheServerID = @CacheServerID

	return 0

go
