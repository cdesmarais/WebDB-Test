if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TmsSync_RestaurantCreditCardMessages_GetAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TmsSync_RestaurantCreditCardMessages_GetAll]
GO

-- Gets all Resturant Credit Card Day Messages

CREATE PROCEDURE dbo.TmsSync_RestaurantCreditCardMessages_GetAll
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT	CCDayID,
		RID,
		BlockedDate,
		Message,
		partysize,
		coalesce(StartTime,'1899-12-30 00:00:00.000') as StartTime,
		coalesce(EndTime,'1899-12-30 23:59:00.000') as EndTime
FROM CreditCardDayVW
WHERE BlockedDate > getdate()-1

GO

GRANT EXECUTE ON [TmsSync_RestaurantCreditCardMessages_GetAll] TO ExecuteOnlyRole

GO
