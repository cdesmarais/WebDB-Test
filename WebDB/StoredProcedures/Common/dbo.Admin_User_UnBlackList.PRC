if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_UnBlackList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_UnBlackList]
GO

--
-- Proc for UnBlacklisting a user account
-- TT 26788 mmc WR2008_11
CREATE PROCEDURE dbo.Admin_User_UnBlackList
(
  @customerID int=0,
  @CallerID int=0
)
AS

BEGIN TRANSACTION


-- set the caller/customer number and flag
IF @CallerID <> 0 
	BEGIN
		-- get rid of the CustomersDeactivated record
		DELETE FROM CustomersDeactivated WHERE CallerID = @CallerID

		--  Set the status to active
		UPDATE	Caller
		SET		CallerStatusID = 1
		WHERE	CallerID = @CallerID
	END
ELSE
	IF @CustomerID <> 0
		BEGIN
		-- regular customer
		-- get rid of the CustomersDeactivated record
		DELETE FROM CustomersDeactivated WHERE CustID = @CustomerID

		--  Set the status to active
		UPDATE	Customer
		SET		Active = 1
		WHERE	CustID = @CustomerID
		END

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
	
GO

GRANT EXECUTE ON [Admin_User_UnBlackList] TO ExecuteOnlyRole

GO
