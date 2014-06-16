if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_ChangeConsumerType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_ChangeConsumerType]
GO

CREATE PROCEDURE dbo.Admin_User_ChangeConsumerType
(
  @customerID int=0,
  @CallerID int=0
)
AS

Declare @OldStatus int

BEGIN TRANSACTION 
if @CallerID = 0
    Begin
    	Select @OldStatus = ConsumerType from Customer where CustID = @customerID
	if @OldStatus = 1
	BEGIN
		Update Customer set ConsumerType = '5' where CustID = @customerID
	END
	else
	BEGIN
		Update Customer set ConsumerType = '1' where CustID = @customerID
	END
    End
if (@@ERROR <> 0)
	goto general_error
if @CallerID > 0
    Begin
    	Select @OldStatus = ConsumerType from Caller where CallerID = @CallerID
	if @OldStatus = 1
	BEGIN
		Update Caller set ConsumerType = '5' where CallerID = @CallerID
	END
	else
	BEGIN
		Update Caller set ConsumerType = '1' where CallerID = @CallerID
	END
    End

  if (@@ERROR <> 0)
	goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_User_ChangeConsumerType] TO ExecuteOnlyRole

GO
