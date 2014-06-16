--$ create proc csServerSetUpTime
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csServerSetUpTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csServerSetUpTime]
GO
CREATE PROCEDURE dbo.csServerSetUpTime
(
	@CacheServerID int
)
as
	-- Set the cache server's up time
	update 	CacheServer
	set 	ActiveDT_UTC 	= getutcdate()
	where 	CacheServerID 	= @CacheServerID

	return 0
go
grant execute on dbo.csServerSetUpTime to ExecuteOnlyRole
go
