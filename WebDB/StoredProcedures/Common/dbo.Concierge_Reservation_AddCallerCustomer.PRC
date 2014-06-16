if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_AddCallerCustomer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_AddCallerCustomer]
GO

CREATE Procedure dbo.Concierge_Reservation_AddCallerCustomer
 (
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @Phone nvarchar(24),
  @CallerID int,
  @SpecialNotes  nvarchar(400),
  @retval int OUTPUT
 )

As

SET NOCOUNT ON
set transaction isolation level read uncommitted

DECLARE @CustID int,@HotelID int
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

SELECT @CustID=CustID 
from CallerCustomer
Where FName=@FirstName 
and LName=@LastName 
and CallerID=@CallerID

if @CustID<>0
	UPDATE CallerCustomer
	SET ContactPhone=@Phone,Notes=@SpecialNotes
	where CustID=@CustID
else
    BEGIN
	INSERT INTO CallCusNextID (CustomerType) VALUES (2)
	SELECT @CustID = scope_identity()
	SELECT @HotelID=CompanyID 
	from Caller 
	Where CallerID=@CallerID
	
	INSERT INTO CallerCustomer (CustID,FName,LName,ContactPhone,CallerID,Notes,CompanyID)
	VALUES (@CustID,@FirstName,@LastName,@Phone,@CallerID,@SpecialNotes,@HotelID)
	
    END
COMMIT TRAN
SET @retval = @CustID
RETURN(0)

go

GRANT EXECUTE ON [Concierge_Reservation_AddCallerCustomer] TO ExecuteOnlyRole

GO
