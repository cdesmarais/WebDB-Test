if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestCCDaysAndMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestCCDaysAndMessages]
GO


CREATE PROCEDURE dbo.ObjectCacheRestCCDaysAndMessages
 AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	RID,
		BlockedDate,
		partysize,
		coalesce(StartTime,'1899-12-30 00:00:00.000') as StartTime,
		coalesce(EndTime,'1899-12-30 23:59:00.000') as EndTime,
		DayID = CCDayID
FROM	CreditCardDay
WHERE	BlockedDate > getdate()-1

-- Retrieve CC day messags which are not null
SELECT		cl.DayID,
			cl.LanguageID,
			cl.Message
FROM		CreditCardDayLocal cl
INNER JOIN	CreditCardDay c
ON			cl.DayID = c.CCDayID
WHERE		BlockedDate > getdate()-1
AND			cl.Message is not null


GO


GRANT EXECUTE ON [ObjectCacheRestCCDaysAndMessages] TO ExecuteOnlyRole

GO
