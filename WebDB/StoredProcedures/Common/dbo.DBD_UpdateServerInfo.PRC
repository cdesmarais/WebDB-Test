if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_UpdateServerInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_UpdateServerInfo]
GO

--**********************************
--** OBSOLETE: EV: Remove proc after deployment of Web_Feature_Monitor2 (June 2008)
--**********************************
CREATE PROCEDURE dbo.DBD_UpdateServerInfo
(
	@ServerID int,
	@WebSite4Version nvarchar(50),
	@WebSite31Version nvarchar(50),
	@OTService nvarchar(50),
	@OT3 nvarchar(50),
	@OTServiceConfigState int,
	@OT3ServiceConfigState int,
	@ChecksumLive nvarchar(50),	
	@ExpectedChecksum nvarchar(50)=0	
)
  
As
--SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

update	WebServerStatus 
set		WebSite4Version = @WebSite4Version,
		WebSite31Version = @WebSite31Version,
		OTService = @OTService,
		OT3 = @OT3,
		OTServiceConfigMatch = @OTServiceConfigState,
		OT3ConfigMatch = @OT3ServiceConfigState,
		ChecksumLive = @ChecksumLive,
		ChecksumExpected = @ExpectedChecksum,
		LastTimeUpdated = getdate()
		where serverID = @ServerID

GO


GRANT EXECUTE ON [DBD_UpdateServerInfo] TO ExecuteOnlyRole

GO