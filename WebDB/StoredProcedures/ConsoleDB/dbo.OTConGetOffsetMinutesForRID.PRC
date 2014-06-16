if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetOffsetMinutesForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetOffsetMinutesForRID]
GO

--
-- Gets the next/previous  reservation given a specific resoID
-- 

CREATE Procedure dbo.OTConGetOffsetMinutesForRID

@RID			INT

AS

-- 
-- returns the OffsetMinutes for the RID
--
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tz.ServerToLocalOffsetMi AS 'ServerTimeToLocalTimeOffsetMinutes'

FROM RestaurantVW r
INNER JOIN TimezoneVW tz ON tz.TZID = r.TZID
WHERE r.RID = @RID

GO

GRANT EXECUTE ON [OTConGetOffsetMinutesForRID] TO ConsoleExecuteRole

GO

