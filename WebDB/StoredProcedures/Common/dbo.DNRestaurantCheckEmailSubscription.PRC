if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantCheckEmailSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantCheckEmailSubscription]
GO

CREATE PROCEDURE dbo.DNRestaurantCheckEmailSubscription
(
    @RestaurantID int,
    @UserID int
)
AS

set transaction isolation level read uncommitted
  If Exists(Select 1 From RestaurantCustomerEmail Where CustID = @UserID And RID = @RestaurantID)
    Begin
    Select retval = 1
    Return(2)
    End


	-- ELSE:
    Select retval = 0
    Return(0)
  
  
GO

GRANT EXECUTE ON [DNRestaurantCheckEmailSubscription] TO ExecuteOnlyRole

GO
