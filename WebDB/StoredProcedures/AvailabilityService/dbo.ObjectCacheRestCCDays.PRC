if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestCCDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestCCDays]
GO


CREATE PROCEDURE dbo.ObjectCacheRestCCDays
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

GO


GRANT EXECUTE ON [ObjectCacheRestCCDays] TO ExecuteOnlyRole

GO
