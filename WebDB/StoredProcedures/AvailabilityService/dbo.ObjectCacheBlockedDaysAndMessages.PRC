if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheBlockedDaysAndMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheBlockedDaysAndMessages]
GO


CREATE PROCEDURE dbo.ObjectCacheBlockedDaysAndMessages
 AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Return just the blocked dates and RID
SELECT  b.RID,
		BlockedDate,
		b.DayID
FROM BlockedDay b
WHERE BlockedDate > getdate()-1


-- Returns a message in all languages supported by the resturant.
-- NOTE: It might be simpler to just have the custom messages and manage the defaults seperately
--			This is currently a challenge because the default message contains the restaurant name
SELECT		bl.DayID, 
			bl.LanguageID, 
			[Message] = coalesce(bl.Message,REPLACE(d.Message,'{0}', rName)) 
FROM		BlockedDayLocal bl
INNER JOIN	BlockedDay b
ON			b.DayID = bl.DayID
INNER JOIN 	[RestaurantLocal] r
ON 			bl.[LanguageID] = r.[LanguageID]
AND			r.rid = b.rid
INNER JOIN	DefaultMessageVW d 
ON			d.MessageTypeID = 1
WHERE		BlockedDate > getdate()-1



GO


GRANT EXECUTE ON [ObjectCacheBlockedDaysAndMessages] TO ExecuteOnlyRole

GO
