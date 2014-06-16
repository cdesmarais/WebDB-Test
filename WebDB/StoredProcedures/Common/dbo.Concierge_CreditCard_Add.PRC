if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_CreditCard_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_CreditCard_Add]
GO

CREATE Procedure dbo.Concierge_CreditCard_Add
  @UserID int,
  @CreditCardNumber nvarchar(255),
  @CreditCardType int,
  @ExpireMonth int,
  @ExpireYear int


As

SET NOCOUNT ON
SET DATEFORMAT mdy

Begin Transaction MyTransaction

set @CreditCardNumber = ltrim(rtrim(@CreditCardNumber))


Declare @Expire smalldatetime
select @Expire=(CONVERT(nvarchar(2),@ExpireMonth)+ '/1/' + CONVERT(nvarchar(4),@ExpireYear))

-- Check that the expiration date on the credit card is not in the past.if DATEPART(YEAR,getdate()) > @ExpireYear 
	GOTO cc_expired 

if (DATEPART(YEAR,getdate()) = @ExpireYear) AND (DATEPART(MONTH,getdate()) > @ExpireMonth) 
	GOTO cc_expired

INSERT INTO CreditCard
(CreditTypeID,CardNumber,ExpDate,CustID )
VALUES (@CreditCardType,@CreditCardNumber,@Expire,@UserID)
if @@error <> 0 
	GOTO cc_general_error

Commit Transaction
Return(1)

cc_general_error:
ROLLBACK TRANSACTION MyTransaction
RAISERROR('5',16,1) --Error inserting credit card.
Return(2)

cc_expired:
ROLLBACK TRANSACTION MyTransaction
RAISERROR('2',16,1) --That credit card has expired.
RETURN(1)

GO

GRANT EXECUTE ON [Concierge_CreditCard_Add] TO ExecuteOnlyRole

GO
