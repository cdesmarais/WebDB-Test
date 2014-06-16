if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_User_AddForEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_User_AddForEmail]
GO



CREATE Procedure dbo.Restaurant_User_AddForEmail
(
    @RestaurantID int,
    @UserID int,
    @CallerID int
)
AS
if (@CallerID = 0)
  Begin
  If Exists(Select 1 From RestaurantCustomerEmail Where CustID = @UserID And RID = @RestaurantID)
    Begin
    Return(2)
    End

    Insert Into RestaurantCustomerEmail (CustID,RID)
    Values(@UserID,@RestaurantID)
  End

 If (@CallerID > 0)
  Begin
  If Exists(Select 1 From RestaurantCustomerEmail Where CallerID = @UserID And RID = @RestaurantID)
    Begin
    Return(1)
    End

    Insert Into RestaurantCustomerEmail (CallerID,RID)
    Values(@CallerID,@RestaurantID)
  End
GO

GRANT EXECUTE ON [Restaurant_User_AddForEmail] TO ExecuteOnlyRole

GO
