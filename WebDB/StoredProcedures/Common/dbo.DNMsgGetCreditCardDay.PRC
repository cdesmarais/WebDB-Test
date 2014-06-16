if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetCreditCardDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetCreditCardDay]
GO



CREATE PROCEDURE dbo.DNMsgGetCreditCardDay
(
  @RID int,
  @BlockedDate datetime
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
SELECT 
    CreditCardDayVW.Message

FROM CreditCardDayVW
WHERE CreditCardDayVW.BlockedDate = @BlockedDate and CreditCardDayVW.RID = @RID
GO

GRANT EXECUTE ON [DNMsgGetCreditCardDay] TO ExecuteOnlyRole

GO
