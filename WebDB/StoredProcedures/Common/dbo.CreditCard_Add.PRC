if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditCard_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditCard_Add]
GO

CREATE Procedure dbo.CreditCard_Add
 (
  @CreditCardType int,
  @CreditCardNumber nvarchar(255),
  @ExpireMonth int,
  @ExpireYear int,
  @UserID int=0,
  @IsCaller int=0,
  @fromnew int=0,
  @IsPrimary int = 1 -- assume primary
)
As

SET NOCOUNT ON
SET DATEFORMAT mdy

DECLARE @CreditCardID int
,@n int

set @CreditCardNumber = ltrim(rtrim(@CreditCardNumber))


SELECT @n = Count(CreditCardID) FROM CreditCard WHERE CardNumber = @CreditCardNumber and CustID = @UserID
if @n > 0
	BEGIN
	Update CreditCard Set lastmodified = getdate() where  CardNumber = @CreditCardNumber and CustID = @UserID
	END
ELSE

BEGIN
Declare @Expire smalldatetime
select @Expire=(CONVERT(nvarchar(2),@ExpireMonth)+ '/1/' + CONVERT(nvarchar(4),@ExpireYear))

GOTO cc_expired

/*insert */
INSERT INTO CreditCard
(CreditTypeID,CardNumber,ExpDate,CustID,IsPrimary)
VALUES (@CreditCardType,@CreditCardNumber,@Expire,@UserID,@IsPrimary)

END
if @@error <> 0
	GOTO cc_general_error

Return(1)

cc_general_error:
	RAISERROR('5',16,1) --Error inserting credit card.
	Return(2)

cc_in_use:
	RAISERROR('3',16,1) --That credit card is in use by 2 people.
	RETURN(3)

cc_expired:
	RAISERROR('2',16,1)
	RETURN(4)
	
GO

GRANT EXECUTE ON [CreditCard_Add] TO ExecuteOnlyRole

GO
