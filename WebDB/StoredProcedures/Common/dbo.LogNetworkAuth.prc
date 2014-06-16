if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LogNetworkAuth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LogNetworkAuth]
GO

-- Record ERB Authentication
CREATE PROCEDURE dbo.LogNetworkAuth
(
	@theRID int,
	@theSourceHostName nvarchar(50),
	@theSourceIP nvarchar(50),
	@theAuthorizationSuccessful bit,
	@theDetails nvarchar(1000),
	@theERBNetworkAddr nvarchar(60),
	@theNetworkAddressUpdated bit
)
As

SET NOCOUNT ON

-- create a tracking log..
INSERT 
	INTO AuthNetworkAddressLog(rid,logdate,srcmachinename,srcipaddress,authsuccess,details,
	reportednetworkaddress,NetworkAddressUpdated)
	
	VALUES
	(@theRID ,
	getdate(),
	@theSourceHostName,
	@theSourceIP,
	@theAuthorizationSuccessful,
	@theDetails,	
	@theERBNetworkAddr,
	@theNetworkAddressUpdated)

GO

GRANT EXECUTE ON [LogNetworkAuth] TO ExecuteOnlyRole

GO
