if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_ChangeOptIn]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_ChangeOptIn]
GO

CREATE PROCEDURE dbo.Admin_User_ChangeOptIn
(
  @customerID int=0,
  @CallerID int=0,
  @action int
)
AS

BEGIN TRANSACTION

DECLARE @MetroAreaID int

if @CallerID = 0
    BEGIN
		SELECT @MetroAreaID = MetroAreaID FROM Customer WHERE CustID = @customerID
		
    	Update Customer set SendAnnouncements = @action where CustID = @customerID
		IF EXISTS(Select CustID from UserOptIn with (nolock) where CustID=@customerID AND MetroAreaID = @MetroAreaID)
			Update UserOptIn
		  		set Insider=@action,DinersChoice=@action,NewHot=@action,RestaurantWeek=@action,Promotional=@action,SpotLight=@action,Product=@action,UpdatedDtUTC=getutcdate()
			where CustID = @customerID
			AND MetroAreaID = @MetroAreaID
		ELSE
			IF EXISTS(Select CustID from Customer with (nolock) where CustID=@customerID AND ConsumerType <> 8) 
				INSERT INTO UserOptIn (CustID, Insider,DinersChoice,NewHot,RestaurantWeek, Promotional,SpotLight, Product,MetroAreaID) 	
					VALUES (@customerID,@action,@action,@action,@action,@action,@action,@action,@MetroAreaID)
    End
if (@@ERROR <> 0)
	goto general_error
if @CallerID > 0
    BEGIN
		SELECT @MetroAreaID = MetroAreaID FROM Caller WHERE CallerID = @CallerID
		
    	Update Caller set SendAnnouncements = @action where CallerID = @CallerID 
		IF EXISTS(Select CallerID from UserOptIn with (nolock) where CallerID=@CallerID AND MetroAreaID = @MetroAreaID)
			Update UserOptIn
			  set Insider=@action,DinersChoice=@action,NewHot=@action,RestaurantWeek=@action,Promotional=@action,SpotLight=@action,Product=@action,UpdatedDtUTC=getutcdate()
			where CallerID = @CallerID
			AND MetroAreaID = @MetroAreaID
		ELSE
			INSERT INTO UserOptIn (CallerID, Insider,DinersChoice,NewHot,RestaurantWeek, Promotional,SpotLight,Product,MetroAreaID) 
			VALUES (@CallerID,@action,@action,@action,@action,@action,@action,@action,@MetroAreaID)
    End

  if (@@ERROR <> 0)
	goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
	
GO

GRANT EXECUTE ON [Admin_User_ChangeOptIn] TO ExecuteOnlyRole

GO
