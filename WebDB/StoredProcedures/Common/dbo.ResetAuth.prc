if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ResetAuth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ResetAuth]
GO

-- Called from ROMS to reset MAC address
CREATE PROCEDURE dbo.ResetAuth
(
	@theRID int,
	@theNewNetworkAddr nvarchar(50)
)
As

SET NOCOUNT ON

-- update the "accept new network address"
update ERBRestaurant
	set NewNetworkAddress = @theNewNetworkAddr
	where rid = @theRID

GO

GRANT EXECUTE ON [ResetAuth] TO ExecuteOnlyRole

GO
