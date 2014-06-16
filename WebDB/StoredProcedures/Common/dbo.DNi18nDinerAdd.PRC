if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNi18nDinerAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNi18nDinerAdd]
GO


CREATE PROCEDURE  dbo.DNi18nDinerAdd

@FirstName nvarchar(60),
@LastName nvarchar(60),
@SortableFirstName nvarchar(60),
@SortableLastName nvarchar(60),
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

	Insert into CallerCustomer (CustID,FName,LName,SFName,SLName,CallerID, CompanyID, Active) 
    	values (@CustID,@FirstName,@LastName, @SortableFirstName,@SortableLastName,@CallerID, @CompanyID, 1)

	IF (@@ERROR <> 0) Goto general_error
	Select @retval = @CustID

COMMIT TRANSACTION @TranName
RETURN(0)

general_error:
ROLLBACK TRANSACTION @TranName
RAISERROR('6',17,1)
RETURN(2)
GO

GRANT EXECUTE ON [DNi18nDinerAdd] TO ExecuteOnlyRole

GO
