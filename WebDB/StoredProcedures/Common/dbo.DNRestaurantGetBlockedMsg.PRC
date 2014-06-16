if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetBlockedMsg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetBlockedMsg]
GO

--*****************************************************************************
--** EV 8/12/04: Created Proc to cache all Blocked Day messages in Web Local Cache
--*****************************************************************************
CREATE PROCEDURE dbo.DNRestaurantGetBlockedMsg
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT distinct b.RID,
		BlockedDate,
		coalesce(b.Message,REPLACE(d.Message,'{0}', rName)) as Message,
		b.RID as RestaurantID
FROM BlockedDayVW b
inner join DefaultMessageVW d on MessageTypeID = 1
INNER JOIN 	[RestaurantLocal] r
ON 		d.[LanguageID] = r.[LanguageID]
AND		r.rid = b.rid
WHERE BlockedDate > getdate()-1
order by b.BlockedDate


GO


GRANT EXECUTE ON [DNRestaurantGetBlockedMsg] TO ExecuteOnlyRole

GO
