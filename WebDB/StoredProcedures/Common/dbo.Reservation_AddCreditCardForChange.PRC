if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_AddCreditCardForChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_AddCreditCardForChange]
GO


CREATE Procedure dbo.Reservation_AddCreditCardForChange
 (
  @ReservationID int,
  @userID int,
  @First_Name nvarchar(255),
  @Last_Name nvarchar(255)
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if exists (select 1 from Reservation where ResID = @ReservationID and CreditCardID is not null)
	Return(1) 
else

	BEGIN
		declare @cc_ID int
	
		Select @cc_ID = (Select top 1 CreditCardID from CreditCard where CustID = @userID order by lastmodified desc)
	
		Update Reservation set CreditCardID = @cc_ID where ResID = @ReservationID
	
		if (@@ERROR <> 0)
			goto general_error
	
	END

Return(2)

general_error:
	Return(0)
GO

GRANT EXECUTE ON [Reservation_AddCreditCardForChange] TO ExecuteOnlyRole

GO
