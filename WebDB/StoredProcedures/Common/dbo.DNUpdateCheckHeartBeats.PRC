if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateCheckHeartBeats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateCheckHeartBeats]
GO

CREATE PROCEDURE dbo.DNUpdateCheckHeartBeats
(
	@nMinutes int,
	@sListenerVersion nvarchar(10)
)
 AS

SET NOCOUNT ON

DECLARE @dNow datetime

SET @dNow = (getUTCdate())

/*
UPDATE Heartbeats SET IsAlive = 0 WHERE (datediff(MI, LastTimeContacted, @dNow)) > @nMinutes  AND
	IsAlive = 1 AND ListenerVersion = @sListenerVersion

UPDATE Heartbeats SET IsAlive = 1 WHERE (datediff(MI, LastTimeContacted, @dNow)) <= @nMinutes  AND
	IsAlive = 0  AND ListenerVersion = @sListenerVersion
*/

UPDATE Restaurant SET IsReachable = 0 WHERE (datediff(MI, (select LTC_UTC from dbo.LastTimeContacted where RID = Restaurant.RID)  , @dNow)) > @nMinutes  AND
	IsReachable = 1 AND (Select count(RID) from dbo.ERBRestaurant erb where (erb.RID = Restaurant.RID) and (erb.ListenerVersion like @sListenerVersion + '%')) = 1

UPDATE Restaurant SET IsReachable = 1 WHERE (datediff(MI, (select LTC_UTC from dbo.LastTimeContacted where RID = Restaurant.RID), @dNow)) <= @nMinutes  AND
	IsReachable = 0 AND (Select count(RID) from dbo.ERBRestaurant erb where (erb.RID = Restaurant.RID) and (erb.ListenerVersion like @sListenerVersion + '%')) = 1
GO


GRANT EXECUTE ON [DNUpdateCheckHeartBeats] TO ExecuteOnlyRole

GO
