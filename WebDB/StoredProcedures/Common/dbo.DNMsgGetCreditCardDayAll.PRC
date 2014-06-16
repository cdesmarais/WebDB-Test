if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetCreditCardDayAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetCreditCardDayAll]
GO




CREATE PROCEDURE dbo.DNMsgGetCreditCardDayAll
(
  @RID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
SELECT 
    CreditCardDayVW.BlockedDate,
    CreditCardDayVW.Message,
    DateBlocked,
	coalesce(StartTime, '12:00 AM') as StartTime,
	coalesce(EndTime, '11:59 PM') as EndTime,
	CreditCardDayVW.CCDayID
FROM CreditCardDayVW
WHERE CreditCardDayVW.RID = @RID
and BlockedDate > getdate()-1
order by CreditCardDayVW.BlockedDate, StartTime, EndTime
GO

GRANT EXECUTE ON [DNMsgGetCreditCardDayAll] TO ExecuteOnlyRole

GO
