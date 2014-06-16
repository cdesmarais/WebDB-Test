if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateCustomerMobioSignup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateCustomerMobioSignup]

GO

/*******************************************************************************
This stored procedure is called when user signup to get OT Mobio App for his mobile phone. 
This procedure updates CustomerPhone table with user's mobile number and also updates a log
table i.e. CustomerMobioSignup, updating a bit stating that user has downloaded app.
********************************************************************************/
CREATE PROCEDURE dbo.DNUpdateCustomerMobioSignup
(
	@CustID int,
	@MobilePhone varchar(24),
	@PhoneCountryID char(2)
)
as

Declare @iPhoneTypeID int 
Set @iPhoneTypeID = 4 -- This PhoneTypeID corresponds to Mobile in PhoneType table.

BEGIN TRANSACTION
		
 --See if CustomerPhone record exists and
--CustomerID record exists in CustomerMobioSignup
IF  NOT EXISTS(SELECT CustID from CustomerPhone where CustID = @CustID and PhoneTypeID = @iPhoneTypeID)
	Begin
		Insert into CustomerPhone(CustID
								  ,PhoneTypeID
								  ,Phone
								  ,PhoneCountryID
								  )
		values					  (@CustID
								  ,@iPhoneTypeID
								  ,@MobilePhone
								  ,@PhoneCountryID
								  )

		if (@@ERROR <> 0)GOTO error_CustPhone

	End
Else
	Begin
		--Assuming the user has just got a new mobile number, update the mobile info.
		Update CustomerPhone Set Phone = @MobilePhone
		Where CustID = @CustID 
			and PhoneTypeID = @iPhoneTypeID 
			and Phone <> @MobilePhone
			
		if (@@ERROR <> 0)GOTO error_UpdateCustPhone
	End


 IF NOT EXISTS(SELECT CustID from CustomerMobioSignup where CustID = @CustID)
 Begin
		--Insert a record into CustomerMobioSignup
		Insert into CustomerMobioSignup(CustID) values (@CustID)
		if (@@ERROR <> 0)GOTO error_CustMobioSignup	
 End

COMMIT TRANSACTION
Return(0)

--Handle Error
error_CustPhone:
	Begin
	ROLLBACK TRANSACTION
	RAISERROR('Cannot Insert into CustomerPhone',16,2) --Error adding new record to CustomerPhone.
	RETURN(1)
	End

error_CustMobioSignup:
	Begin
	ROLLBACK TRANSACTION
	RAISERROR('Cannot Insert into CustomerMobioSignup',16,2) --Error adding new record to CustomerMobioSignup.
	RETURN(2)
	End

error_UpdateCustPhone:
	Begin
	ROLLBACK TRANSACTION
	RAISERROR('Cannot Update CustomerPhone',16,1) --Error updating Customer mobile number.
	RETURN(3)
	End
Go

GRANT EXECUTE ON [DNUpdateCustomerMobioSignup] TO ExecuteOnlyRole

Go

