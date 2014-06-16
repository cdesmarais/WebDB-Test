if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantAddEmailSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantAddEmailSubscription]
GO



CREATE PROCEDURE dbo.DNRestaurantAddEmailSubscription
(
    @RestaurantID int,
    @UserID int
)
AS

  Begin
  If Exists(Select 1 From RestaurantCustomerEmail Where CustID = @UserID And RID = @RestaurantID)
    Begin
    Return(2)
    End

    Insert Into RestaurantCustomerEmail (CustID,RID)
    Values(@UserID,@RestaurantID)
  End
GO

GRANT EXECUTE ON [DNRestaurantAddEmailSubscription] TO ExecuteOnlyRole

GO
