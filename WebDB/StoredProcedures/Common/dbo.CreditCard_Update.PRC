if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditCard_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditCard_Update]
GO



CREATE PROCEDURE dbo.CreditCard_Update
 (
  @CreditCardType int,
  @CreditCardNumber nvarchar(255),
  @ExpireMonth int,
  @ExpireYear int,
  @CreditID int,
  @CustomerID int = 0,
  @IsPrimary int = 1 --assume is primary credit card that is being updated
)

/*8-7-00 this stored proc functionality needed reworking for new credit card schema... changes also necessary in logic where used!!!
This stored proc and encapsulating logic should be reworked as soon as possible!*/
As
SET NOCOUNT ON

DECLARE @n int
SELECT @n= COUNT(*)
FROM CreditCard
WHERE (CardNumber = @CreditCardNumber)if @n > 2 GOTO cc_in_use

SET DATEFORMAT mdy
Declare @Expire smalldatetime
select @Expire=(CONVERT(nvarchar(2),@ExpireMonth)+ '/1/' + CONVERT(nvarchar(4),@ExpireYear))

--check for valid expiration dateif Datediff(m,@Expire,getdate()) > 1 
		GOTO cc_expired
if @CustomerID = 0
   BEGIN
	UPDATE CreditCard
	SET CreditTypeID=@CreditCardType,
	CardNumber=@CreditCardNumber,
	ExpDate=@Expire,
	StatusID=1,
	IsPrimary = @IsPrimary
	WHERE CreditCardID=@CreditID
   END
ELSE
   BEGIN
	UPDATE CreditCard
	SET CreditTypeID=@CreditCardType,
	CardNumber=@CreditCardNumber,
	ExpDate=@Expire,
	StatusID=1,
	IsPrimary = @IsPrimary
	WHERE CustID = @CustomerID
   END
if @@error <> 0
   BEGIN
	RaisError('39',16,1) --'Error updating credit card.'
             Return(2)
   END

Return (0)

cc_in_use:
RAISERROR('3',16,1) --'That credit card is in use by 2 people.'
RETURN(1)

cc_expired:
RAISERROR('2',16,1)
RETURN(2)
GO

GRANT EXECUTE ON [CreditCard_Update] TO ExecuteOnlyRole

GO
