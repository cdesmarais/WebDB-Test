if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_Reservation_DinerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_Reservation_DinerUpdate]
GO

CREATE PROCEDURE dbo.AA_Reservation_DinerUpdate
(
@Caller_ID int,
@ReservationID int,
@FirstName nvarchar(255),
@LastName nvarchar(255)
)
AS
SET NOCOUNT ON

DECLARE @retval int,@CustID int
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION  UpdateTran

if exists(Select CustID from CallerCustomer where FName = @FirstName and LName = @LastName and CallerID = @Caller_ID)
BEGIN
	Select @CustID = CustID
	from CallerCustomer 
	where FName = @FirstName and LName = @LastName and CallerID = @Caller_ID
END

else

BEGIN

	INSERT INTO CallCusNextID (CustomerType) VALUES ('S')
	IF (@@ERROR <> 0) Goto general_error

	Select @CustID = scope_identity()

	Insert into CallerCustomer (CustID,FName,LName,CallerID, Active) 
    	values (@CustID,@FirstName,@LastName,@Caller_ID,1)

	IF (@@ERROR <> 0) Goto general_error

END


Update Reservation set CustID = @CustID where ResID = @ReservationID and CallerID = @Caller_ID


COMMIT TRANSACTION UpdateTran 
Return(0)

general_error:
ROLLBACK TRANSACTION  UpdateTran 
RAISERROR('7',17,1)
RETURN(2)

GO

GRANT EXECUTE ON [AA_Reservation_DinerUpdate] TO ExecuteOnlyRole

GO
