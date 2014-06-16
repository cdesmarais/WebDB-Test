if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DinerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DinerUpdate]
GO

CREATE PROCEDURE dbo.AA_DinerUpdate
(
@CustomerID      int
,@Email          nvarchar(255)
,@FirstName      nvarchar(255)
,@LastName       nvarchar(255)
,@ContactPhone   nvarchar(24)
,@PhoneExtension nvarchar(6)
)
AS

SET NOCOUNT ON

DECLARE  @n int
	,@newflg int
	   
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION  DrewTran

   Update CallerCustomer 
   set	 Email  = @Email
	,FName  = @FirstName
	,LName  = @LastName
   where CustID = @CustomerID
   
   IF (@@ERROR <> 0) Goto general_error
   IF (@@ERROR <> 0) Goto general_error

COMMIT TRANSACTION DrewTran 
Return(0)

general_error:
ROLLBACK TRANSACTION  DrewTran 
RAISERROR('7',17,1)
RETURN(2)


GO

GRANT EXECUTE ON [AA_DinerUpdate] TO ExecuteOnlyRole

GO
