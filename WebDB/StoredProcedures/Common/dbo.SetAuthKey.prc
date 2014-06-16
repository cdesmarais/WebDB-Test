if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SetAuthKey]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SetAuthKey]
GO

-- Resets the network authentication key in ERBRestaurant. This also resets the NewNetworkAddress field. 
CREATE PROCEDURE dbo.SetAuthKey
(
	@theRID int,
	@theSourceHostName nvarchar(50),
	@theSourceIP nvarchar(50),
	@theAuthorizationSuccessful bit,
	@theDetails nvarchar(1000),
	@theERBNetworkAddr nvarchar(60)
)
As

SET NOCOUNT ON

declare @theNetworkAddressUpdated bit
set @theNetworkAddressUpdated = 0

-- Set data in ERBRestaurant first
update ERBRestaurant
	SET
		NetworkAddress=@theERBNetworkAddr,
		NewNetworkAddress=NULL
	
	WHERE 
		RID=@theRID
		AND 
		(
			(NetworkAddress IS NULL AND NewNetworkAddress IS NULL)
				OR
			(NewNetworkAddress = @theERBNetworkAddr)
		)
		
-- If an update occurred then 
set @theNetworkAddressUpdated = @@rowcount
	
-- now track this change..
exec dbo.LogNetworkAuth 
	@theRID,
	@theSourceHostName,
	@theSourceIP,
	@theAuthorizationSuccessful,
	@theDetails,
	@theERBNetworkAddr,
	@theNetworkAddressUpdated

GO

GRANT EXECUTE ON [SetAuthKey] TO ExecuteOnlyRole

GO
