if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_User_CheckForEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_User_CheckForEmail]
GO

CREATE PROCEDURE dbo.Restaurant_User_CheckForEmail
(
    @RestaurantID int,
    @UserID int,
    @IsCaller int
)
AS

set transaction isolation level read uncommitted

if Not Exists(Select 1 From ERBRestaurant 
	Inner Join Restaurant r On ERBRestaurant.RID = r.RID
	Where ERBRestaurant.RID = @RestaurantID /*And ERBBuild >= 251 */And Allotment = 0)
  Begin
  Select retval = 0
  Return(1)
  End
if (@IsCaller = 0)
  Begin
  If Exists(Select 1 From RestaurantCustomerEmail Where CustID = @UserID And RID = @RestaurantID)
    Begin
    Select retval = 0
    Return(2)
    End

    Select retval = 1
    Return(0)
  End

 If (@IsCaller > 0)
  Begin
  If Exists(Select 1 From RestaurantCustomerEmail Where CallerID = @UserID And RID = @RestaurantID)
    Begin
    Select retval = 0
    Return(2)
    End

    Select retval = 1
    Return(0)
  End
GO

GRANT EXECUTE ON [Restaurant_User_CheckForEmail] TO ExecuteOnlyRole

GO
