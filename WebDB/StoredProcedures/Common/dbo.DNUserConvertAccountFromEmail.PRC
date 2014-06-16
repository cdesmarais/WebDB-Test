
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserConvertAccountFromEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserConvertAccountFromEmail]
GO


CREATE Procedure dbo.DNUserConvertAccountFromEmail
 (
  @UserEmail nvarchar(50)
  )
As

SET NOCOUNT ON

BEGIN TRAN
--*************************
--** Convert From Annon To Admin
--*************************

Declare @Customer_ID as int, @Original_Consumer_Type_ID as int, @Caller_ID as int

Select @Customer_ID = Custid, @Original_Consumer_Type_ID = ConsumerType from customer where email = @UserEmail

--********************************
--** DeActivate Current Customer Record
--** And Create a new Active Caller based on the Customer Record
--** Update all Caller Related Data
--********************************
Exec DNChangeRealCustomerToAAUser @CustomerEmail = @UserEmail
if (@@error <> 0)
	GOTO general_error
Select @Caller_ID = CallerID from Caller where loginname = @UserEmail

-- Insert CallerToken, delete CustomerToken
insert into CallerToken (CallerID, [Hash], Salt, UserTokenTypeID)
select @Caller_ID, [Hash], salt, UserTokenTypeID from CustomerToken
where CustID = @Customer_ID 

DELETE CustomerToken WHERE CustID = @Customer_ID


--********************************
--** Log the Conversion
--********************************
Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @Caller_ID,@Original_Consumer_Type_ID = @Original_Consumer_Type_ID,@New_Consumer_Type_ID = @Original_Consumer_Type_ID

if (@@error <> 0)
	GOTO general_error

Select CallerID as UserID,email,FName as First_Name,1 as Updated from Caller where loginname = @UserEmail

	
COMMIT TRAN
RETURN(0)

general_error:
ROLLBACK TRAN
RAISERROR('143',16,1)
RETURN(1)

GO


GRANT EXECUTE ON [DNUserConvertAccountFromEmail] TO ExecuteOnlyRole

GO
