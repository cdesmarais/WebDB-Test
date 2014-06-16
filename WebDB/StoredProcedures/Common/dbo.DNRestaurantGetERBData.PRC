if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetERBData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetERBData]
GO


CREATE   Procedure dbo.DNRestaurantGetERBData
(
	@nRestaurantID int
)

As

set transaction isolation level read uncommitted
SET NOCOUNT ON

SELECT 
			 ERBRestaurant.ServerIP AS IP
			, ERBRestaurant.serverPwd AS AccessPassword
			, ERBRestaurant.ERBVersion
			, ERBRestaurant.ListenerVersion
			, ERBRestaurant.ProductID

FROM		ERBRestaurant
WHERE		ERBRestaurant.RID = @nRestaurantID


GO


GRANT EXECUTE ON [DNRestaurantGetERBData] TO ExecuteOnlyRole

GO
