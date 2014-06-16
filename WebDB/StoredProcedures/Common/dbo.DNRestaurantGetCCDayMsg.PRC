if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetCCDayMsg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetCCDayMsg]
GO

--*****************************************************************************
--** EV 8/12/04: Created Proc to cache all Blocked CC Day messages in Web Local Cache
--** EV 2/23/05: Added Party Size
--*****************************************************************************
CREATE PROCEDURE dbo.DNRestaurantGetCCDayMsg
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT distinct RID,
		BlockedDate,
		Message,
		partysize,
		coalesce(StartTime,'1899-12-30 00:00:00.000') as StartTime,
		coalesce(EndTime,'1899-12-30 23:59:00.000') as EndTime
FROM CreditCardDayVW
WHERE BlockedDate > getdate()-1

GO


GRANT EXECUTE ON [DNRestaurantGetCCDayMsg] TO ExecuteOnlyRole

GO
