if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantAddEmailSubscription_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantAddEmailSubscription_V2]
GO



CREATE PROCEDURE dbo.DNRestaurantAddEmailSubscription_V2
(
    @RestaurantID int,
    @UserID int,
    @IsCallerOrAdmin bit
)
AS

Begin
  If (@IsCallerOrAdmin = 1)
  Begin
/*
  	If Exists(Select 1 From RestaurantCustomerEmail Where CallerID = @UserID And RID = @RestaurantID)
	Begin
	    Return(2)
   	End
   	
  	Insert Into RestaurantCustomerEmail (CallerID, RID) Values(@UserID,@RestaurantID)
*/
  	Return(2) -- Temporary Fix. Caller handling is failing
  End
  Else
  Begin
  	If Exists(Select 1 From RestaurantCustomerEmail Where CustID = @UserID And RID = @RestaurantID)
  	Begin
             Return(2)
        End
     
     Insert Into RestaurantCustomerEmail (CustID,RID) Values(@UserID,@RestaurantID)
  End
End
GO

GRANT EXECUTE ON [DNRestaurantAddEmailSubscription_V2] TO ExecuteOnlyRole

GO
