if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNDinerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNDinerUpdate]
GO

CREATE PROCEDURE dbo.DNDinerUpdate
(
@CustomerID      int
,@FirstName      nvarchar(60)
,@LastName       nvarchar(60)
)
AS
SET NOCOUNT ON

	   
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION  DrewTran

   Update CallerCustomer 
   set	 
	FName  = @FirstName
	,LName  = @LastName
   where CustID = @CustomerID
   
   IF (@@ERROR <> 0) Goto general_error
   
COMMIT TRANSACTION DrewTran 
Return(0)

general_error:
ROLLBACK TRANSACTION  DrewTran 
RAISERROR('7',17,1)
RETURN(2)
GO

GRANT EXECUTE ON [DNDinerUpdate] TO ExecuteOnlyRole

GO
