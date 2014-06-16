if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheBlockedDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheBlockedDates]
GO


CREATE PROCEDURE dbo.ObjectCacheBlockedDates
 AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*******************************
-- Return just the blocked dates and RID
--*******************************
SELECT  b.RID,
		BlockedDate,
		b.DayID
FROM BlockedDay b
WHERE BlockedDate > getdate()-1

GO


GRANT EXECUTE ON [ObjectCacheBlockedDates] TO ExecuteOnlyRole

GO
