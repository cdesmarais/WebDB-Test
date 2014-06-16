if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNDinerAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNDinerAdd]
GO

CREATE PROCEDURE  dbo.DNDinerAdd

@FirstName nvarchar(60),
@LastName nvarchar(60),
@CallerID int,
@retval int = 0 OUTPUT

AS
SET NOCOUNT ON
 
DECLARE @UserID int,@n tinyint,@CreditCardID int,@CustID int,@TranName nvarchar(20)
Select @TranName = 'MyTransaction'
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION @TranName

--1. INSERT NEW CallerCustomer

	INSERT INTO CallCusNextID (CustomerType) VALUES ('S')
	IF (@@ERROR <> 0) Goto general_error

	Select @CustID = scope_identity()
	
	declare @CompanyID int
	select @CompanyID = CompanyID from caller where CallerID = @CallerID
	IF (@@ERROR <> 0) Goto general_error

	Insert into CallerCustomer (CustID,FName,LName,CallerID, CompanyID, Active) 
    	values (@CustID,@FirstName,@LastName, @CallerID, @CompanyID, 1)

	IF (@@ERROR <> 0) Goto general_error
	Select @retval = @CustID

COMMIT TRANSACTION @TranName
RETURN(0)

general_error:
ROLLBACK TRANSACTION @TranName
RAISERROR('6',17,1)
RETURN(2)
GO

GRANT EXECUTE ON [DNDinerAdd] TO ExecuteOnlyRole

GO
