if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_ChangeStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_ChangeStatus]
GO

CREATE PROCEDURE dbo.Admin_User_ChangeStatus
(
  @customerID int=0,
  @CallerID int=0,
  @status int
)
AS

BEGIN TRANSACTION

	if @CallerID = 0
		-- disallow status change for blacklisted users
		IF EXISTS  (SELECT	*
					FROM	CustomersDeactivated
					WHERE	CustID = @CustomerID AND ReasonID = 8)
			BEGIN
			ROLLBACK TRANSACTION
			RAISERROR('Cannot change status of blacklisted customers.', 16,1)
			END

    Begin
    Update Customer set Active = @status where CustID = @customerID
	/*
	if @status = 0
	BEGIN
		Update Customer set Email = Email + 'DEACTIVATED' where CustID = @customerID
	END
	else
	BEGIN
		if exists(Select Email from Customer where CustID = @customerID and email like '%DEACTIVATED')
		BEGIN
			Update Customer set Email = left(Email,len(Email)-11) where CustID = @customerID
		END
	END
	*/
    End
if (@@ERROR <> 0)
	goto general_error
if @CallerID > 0
		-- disallow status change for blacklisted callers
		IF EXISTS  (SELECT	*
					FROM	CustomersDeactivated
					WHERE	CallerID = @CallerID AND ReasonID = 8)
			BEGIN
			ROLLBACK TRANSACTION
			RAISERROR('Cannot change status of blacklisted callers.', 16,1)
			END

    Begin
    Update Caller set callerstatusid = @status where CallerID = @CallerID
	/*
	if @status = 0
	BEGIN
		Update Caller set Email = Email + 'DEACTIVATED' where CallerID = @CallerID
	END
	else
	BEGIN
		if exists(Select Email from Caller where CallerID = @CallerID and email like '%DEACTIVATED')
		BEGIN
			Update Caller set Email = left(Email,len(Email)-11) where CallerID = @CallerID
		END
	END
	*/
    End
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
	
GO

GRANT EXECUTE ON [Admin_User_ChangeStatus] TO ExecuteOnlyRole

GO
