if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsRegisterCacheServer]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsRegisterCacheServer]
GO

CREATE PROCEDURE dbo.OpsRegisterCacheServer
(
	@DestServerIP nvarchar(100),
	@InternalServerName nvarchar(100),
	@PublicServerName nvarchar(100)
)
As

--*******************************
--** Proc is used to create an in-active server
--** If server already exists no action is taken
--** If server with same IP or Hostname exists then it is de-activated and this server is created
--******************************
declare @ServerID int
declare @CacheServerID int
if not exists(select IPAddress from Server where IPAddress = @DestServerIP and ServerName = @InternalServerName)
begin
	begin transaction
		-- Server does not already exist
		-- 1) Deactive any server that had previously used this IPaddress or Server Name
		update	Server
		set		Active = 0,
				AcceptsTraffic = 0,
				updatedt = getdate()
		where	IPAddress = @DestServerIP 
		or		ServerName = @InternalServerName

		-- 2) Create a New Server Entry
		insert Server (IPAddress, ServerName, AcceptsTraffic, Active, ImageUploadTransactionID, updatedt)
			values (@DestServerIP, @InternalServerName, 0, 0, 0, getdate())
		select @ServerID = scope_identity()

		select @CacheServerID = (select max(CacheServerID) + 1 from CacheServer)
		insert into CacheServer (CacheServerID, InternalDNS, PortNumber, ServerID) 
			values (@CacheServerID, @DestServerIP, 2369, @ServerID)
		

		-- Create Cache server group, cloning the existing default group	
		insert into CacheServerERBGroup
			select 
					(select max(CacheServerERBGroupID) + 1 from CacheServerERBGroup where CacheServerERBGroupID < 100 and CacheServerERBGroupID != 10),
					@CacheServerID, 
					@PublicServerName, 
					csg.destwebserver, 
					'Primary', 
					0 
			from	CacheServerERBGroup csg 
			where	IsDefaultGroup = 1
	commit
end
GO

GRANT EXECUTE ON [OpsRegisterCacheServer] TO ExecuteOnlyRole

GO

