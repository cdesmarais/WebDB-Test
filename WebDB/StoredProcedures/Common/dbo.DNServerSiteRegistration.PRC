if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNServerSiteRegistration]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNServerSiteRegistration]
GO


CREATE PROCEDURE dbo.DNServerSiteRegistration
(
	@StaticChecksumExpected nvarchar(50), 
	@IPAddress nvarchar(50), 
	@Instance nvarchar(100), 
	@VersionNumberLive nvarchar(50),
	@StaticChecksumLive nvarchar(50),	
	@DynamicChecksumLive nvarchar(50)
)
As
--**************************************
--** Proc is used to Register a ServerSite will create a ServerSite record if one doesn't exist
--**************************************

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--force null values to be '0' instead of null. This prevents a bug in the DAshboard
select	@StaticChecksumLive = isnull(@StaticChecksumLive, '0'), 
		@DynamicChecksumLive = isnull(@DynamicChecksumLive, '0')

--*************************
--** Step 1a: Retrieve SiteType
--*************************
declare @d_SiteTypeID int
declare @d_ServerID int

select	@d_SiteTypeID = st.SiteTypeID
from	SiteType st
where	st.Instance = @Instance

--*************************
--** Step 1b: If Record doesn't Exist, then map it to 0 "unknown" handled in update /insert statement
--*************************


--*************************
--** Step 2a: Retrieve ServerID
--*************************
select	@d_ServerID = s.serverID
from	Server s
where	s.IPAddress = @IPAddress

--*************************
--** Step 2b: If a Server Record doesn't Exist, Create it
--*************************
if (@d_ServerID is null)
begin
	-- If there is already a server with the same name that is not active then rename it, to allow a new active server to be created.
	if exists (select serverID from Server where ServerName = HOST_NAME() and active = 0)
	begin
		update Server set ServerName = ServerName + '_' + convert(varchar(20), ServerID),  
							IPAddress = IPAddress + '_' + convert(varchar(20), ServerID)
		where ServerName = HOST_NAME() and active = 0
	end

	insert into Server (IPAddress, ServerName, AcceptsTraffic, Active, ImageUploadTransactionID, UpdateDT, LBStatusCode) 
	values (@IPAddress, HOST_NAME(), 1, 1, 0, getdate(), 1)
	set @d_ServerID = scope_identity()
end


--*************************
--** Step 3a: Set the Server Site Data
--*************************
update	ServerSite 
set		StaticChecksumExpected = @StaticChecksumExpected, 
		UpdateDT = getdate(), 
		VersionNumberLive = @VersionNumberLive, 
		StaticChecksumLive = @StaticChecksumLive, 
		DynamicChecksumLive = @DynamicChecksumLive
where	ServerID = IsNull(@d_ServerID, 0) -- If null then default to unknown
and		SiteTypeID = IsNull(@d_SiteTypeID, 0) -- If null then default to unknown

IF @@ROWCOUNT = 0
BEGIN
--*************************
--** Step 3b: If Update failed assume record didn't exist, insert record
--*************************
insert into ServerSite (
		StaticChecksumExpected, 
		UpdateDT, 
		SiteTypeID, 
		ServerID, 
		VersionNumberLive, 
		StaticChecksumLive, 
		DynamicChecksumLive) 
values (
		@StaticChecksumExpected, 
		getdate(), 
		IsNull(@d_SiteTypeID, 0), 
		IsNull(@d_ServerID, 0), 
		@VersionNumberLive, 
		@StaticChecksumLive, 
		@DynamicChecksumLive
	)
END

if (@d_ServerID is null)
begin
 declare @errMessage nvarchar(2000)
 set @errMessage = 'Rogue Server or Site IP:'+ IsNull(@IPAddress,'null') + ' Instance:' + IsNull(@Instance, 'null')
 RAISERROR(@errMessage ,17,1)
end


GO

GRANT EXECUTE ON [DNServerSiteRegistration] TO ExecuteOnlyRole

GO
-- also permit Console use
GRANT EXECUTE ON [DNServerSiteRegistration] TO ConsoleExecuteRole

GO

