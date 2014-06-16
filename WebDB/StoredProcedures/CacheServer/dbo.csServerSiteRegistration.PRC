--$ create proc csServerSiteRegistration
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csServerSiteRegistration]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csServerSiteRegistration]
GO
CREATE PROCEDURE dbo.csServerSiteRegistration
(
	 @IPAddress              nvarchar(50)
	,@VersionNumberLive      nvarchar(50)
	,@StaticChecksumExpected nvarchar(50)	
	,@StaticChecksumLive     nvarchar(50)	
)
as
	declare  @Instance  	nvarchar(50)
			,@ServerID		int
			,@CacheServerID int

	-- Get ServerID based on IP address
	select 	 @ServerID = ServerID
			,@Instance = 'CacheServer'
	from	Server		where IPAddress = @IPAddress

	if @ServerID is null return -1

	-- Find cache server ID (there is only 1 CS per IP address)
	select  @CacheServerID = CacheServerID
	from	CacheServer where ServerID  = @ServerID

	if @CacheServerID is null return -2

	set @StaticChecksumExpected = coalesce(@StaticChecksumExpected, '0')
	set @StaticChecksumLive = coalesce(@StaticChecksumLive, '0')
	set @VersionNumberLive = coalesce(@VersionNumberLive, '0')

	-- Update server registration
	exec dbo.DNServerSiteRegistration 
		 @StaticChecksumExpected
		,@IPAddress
		,@Instance
		,@VersionNumberLive
		,@StaticChecksumLive
		,'0'

	-- Return the ID to the calling cache server
	select 	CacheServerID
	from 	CacheServer
	where 	CacheServerID = @CacheServerID

	return 0
go
grant execute on dbo.csServerSiteRegistration to ExecuteOnlyRole
go
