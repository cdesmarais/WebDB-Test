if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_Add_Credit_Card]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_Add_Credit_Card]
GO





CREATE Procedure dbo.Reservation_Add_Credit_Card
 (
  @ReservationID int,
  @userID int,
  @First_Name nvarchar(255),
  @Last_Name nvarchar(255)
 )
As
/* revised 11/10/2003 for new credit card schema */
SET NOCOUNT ON
BEGIN TRANSACTION

declare @cc_ID int

Select @cc_ID = (Select top 1 CreditCardID from CreditCard where CustID = @userID order by lastmodified desc)

Update Reservation set CreditCardID = @cc_ID where ResID = @ReservationID

/*INSERT INTO Guarantee
 (
  ResID,
  GCCID,
  GFName,
  GLName
 )
VALUES
 (
  @ReservationID,
  @cc_ID,
  @First_Name,
  @Last_Name
 )
*/
if (@@ERROR <> 0)
	goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Reservation_Add_Credit_Card] TO ExecuteOnlyRole

GO
