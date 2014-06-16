if exists (select * from dbo.sysobjects where id = object_id(N'dbo.OpsRegisterServer') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.OpsRegisterServer
GO

CREATE PROCEDURE dbo.OpsRegisterServer
(
	@DestServerIP nvarchar(100),
	@DestServerName nvarchar(100)
)
As

--*******************************
--** Proc is used to create an inactive server
--** If server already exists no action is taken
--** If server with same IP or Hostname exists then it is de-activated and this server is created
--******************************(
if not exists(select IPAddress from [Server] where IPAddress = @DestServerIP and ServerName = @DestServerName)
begin
	-- Server does not already exist
	-- 1) Deactive any server that had previously used this IPaddress or Server Name
	update	dbo.[Server]
	set		Active = 0,
			AcceptsTraffic = 0,
			updatedt = getdate(),
			LBStatusCode = 0				-- LBStatusCode = 0 = OTWEB_OFF
	where	IPAddress = @DestServerIP 
	or		ServerName = @DestServerName

	declare @ServerID int

	-- 2) create a new Server Entry
	insert into [dbo].[Server]    
		(IPAddress
		,ServerName
		,AcceptsTraffic
		,Active           
		,ImageUploadTransactionID
		,UpdateDT 
		,LBStatusCode)
	values                           
		(@DestServerIP             
		,@DestServerName         
		,0                         
		,0                         
		,0                         
		,GetDate()                 
		,0)									-- LBStatusCode = 0 = OTWEB_OFF
		                       
end
go

grant execute on [OpsRegisterServer] to ExecuteOnlyRole
go

