if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsSynchServer]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsSynchServer]
GO

CREATE PROCEDURE dbo.OpsSynchServer
(
	@SourceServerIP nvarchar(100), 
	@DestServerIP nvarchar(100),
	@DestServerName nvarchar(100)
)
As

--*******************************
--** Proc is used to synchronize a server (usually a new server) with a prexisting server
--** If a new server is created it is always off the loadbalancer
--******************************(

declare @ImageUploadTransactionID int

--*****************
--** Retrieve the ImageUploadID
--*****************
select	@ImageUploadTransactionID = ImageUploadTransactionID
from	server
where	IPAddress = @SourceServerIP

if @ImageUploadTransactionID is null
begin
	RAISERROR('### Could not find Source Server',17,1)
end


--*****************
--** Register the Server (if not already registered)
--*****************
exec OpsRegisterServer @DestServerIP, @DestServerName

--*****************
--** Set ImageUploadID
--*****************
update	Server
set		ImageUploadTransactionID = @ImageUploadTransactionID,
		updatedt = getdate()
where	IPAddress = @DestServerIP 
and		ServerName = @DestServerName
		
GO

GRANT EXECUTE ON [OpsSynchServer] TO ExecuteOnlyRole

GO

