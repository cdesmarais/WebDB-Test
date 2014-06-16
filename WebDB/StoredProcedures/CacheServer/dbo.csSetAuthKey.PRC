--$ create proc csSetAuthKey
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csSetAuthKey]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csSetAuthKey]
GO

CREATE PROCEDURE dbo.csSetAuthKey
(
	 @RID					int
	,@NetworkAddress		varchar(60)
)
As

update ERBRestaurant
set
	 NetworkAddress			= @NetworkAddress
	,NewNetworkAddress		= case
								when NewNetworkAddress = @NetworkAddress 
								then null
								else NewNetworkAddress
							  end
where RID = @RID
			
GO

GRANT EXECUTE ON [csSetAuthKey] TO ExecuteOnlyRole
GO
