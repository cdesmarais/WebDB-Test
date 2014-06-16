if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantUpdateStateIDFromIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantUpdateStateIDFromIP]
GO

CREATE PROCEDURE dbo.DNRestaurantUpdateStateIDFromIP
(
	@ServerIP nvarchar(255),
	@nRestStateID int
)
 AS

SET NOCOUNT ON

declare @nRestaurantID as int

select @nRestaurantID = RID from ERBRestaurant where ServerIP = @ServerIP 

exec DNRestaurantUpdateStateID @nRestaurantID, @nRestStateID
GO



GRANT EXECUTE ON [DNRestaurantUpdateStateIDFromIP] TO ExecuteOnlyRole

GO
