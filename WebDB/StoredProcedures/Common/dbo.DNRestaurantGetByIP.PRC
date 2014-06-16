if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetByIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetByIP]
GO

CREATE PROCEDURE dbo.DNRestaurantGetByIP
(
	@ServerIP nvarchar(255),
	@ServerPwd nvarchar(255)
)

As

SET NOCOUNT ON

declare @nRestaurantID as int

select @nRestaurantID = RID from ERBRestaurant where ServerIP = @ServerIP and ServerPwd = ServerPwd

exec DNRestaurantGetByID @nRestaurantID
GO



GRANT EXECUTE ON [DNRestaurantGetByIP] TO ExecuteOnlyRole

GO
