--$ create proc dbgRegisterCacheServer
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgRegisterCacheServer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgRegisterCacheServer]
go
create proc dbgRegisterCacheServer
(
	  @IPAddress nvarchar(255)
	, @Hostname nvarchar(255)
	, @DestCacheServer nvarchar(255)
	, @DestWebServer nvarchar(255)
	, @Groupname nvarchar(255)
)
as

	exec OpsRegisterServer @IPAddress, @Hostname	

	declare  @ServerID 		int
	 		,@CacheServerID int
			,@GroupID		int

	select @CacheServerID 	= coalesce(max(CacheServerID), 0)         + 1 from CacheServer
	select @GroupID 		= coalesce(max(CacheServerERBGroupId), 0) + 1 from CacheServerERBGroup
	select @ServerID 		= ServerID from Server where ServerName = @Hostname

	insert into CacheServer ( CacheServerID, InternalDNS, PortNumber, ServerID )
	values ( @CacheServerID, @Hostname, 2369, @ServerID )

	insert into CacheServerERBGroup ( CacheServerERBGroupId, CacheServerId, DestCacheServer, DestWebServer, GroupName )
	values ( @GroupID, @CacheServerId, @DestCacheServer, @DestWebServer, @GroupName )

	select @CacheServerId 'CacheServerID', @GroupID 'GroupID', @ServerID 'ServerID'

	return 0

go
