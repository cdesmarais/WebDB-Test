if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConDNGetLastTimestamp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConDNGetLastTimestamp]
GO

CREATE Procedure dbo.OTConDNGetLastTimestamp

@RID INT

AS

--
-- returns the 'create date' of the DayBehind by returning the last reso datemade
--

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @LatestTime DATETIME

SELECT TOP 1	@LatestTime = UpdateDT
FROM			ReservationLog rl
ORDER BY		rl.ResLogID DESC

SELECT	DATEADD(MI, tz.ServerToLocalOffsetMi, @LatestTime)
FROM	Restaurant r

INNER JOIN	TimeZoneVW tz
ON			tz.TZID = r.TZID

WHERE		r.RID = @RID


GO

GRANT EXECUTE ON [OTConDNGetLastTimestamp] TO ConsoleExecuteRole

GO

