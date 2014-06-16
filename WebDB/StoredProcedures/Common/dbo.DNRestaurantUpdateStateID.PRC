if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantUpdateStateID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantUpdateStateID]
GO

CREATE PROCEDURE dbo.DNRestaurantUpdateStateID
(
	@nRestaurantID int,
	@nRestStateID int
)
 AS

SET NOCOUNT ON

declare @bStateUpdated	bit

Update Restaurant 
set RestStateID = @nRestStateID 
where RID = @nRestaurantID
and RestStateID != @nRestStateID

-- status tracking
set @bStateUpdated = @@rowcount

if (@bStateUpdated = 1)
BEGIN
	-- track change 
	EXEC dbo.Admin_AuditRestStatusChg @nRestaurantID,'Website4.0',@nRestStateID
END

GO



GRANT EXECUTE ON [DNRestaurantUpdateStateID] TO ExecuteOnlyRole

GO
