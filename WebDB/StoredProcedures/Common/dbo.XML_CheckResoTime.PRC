if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_CheckResoTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_CheckResoTime]
GO

CREATE PROCEDURE dbo.XML_CheckResoTime
(
  @RestaurantID int,
  @ResDateTime datetime
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @realtime as datetime


Select		@realtime = currentLocalTime
From		Restaurant r
inner join	TimeZoneVW tz
on			r.TZID = tz.TZID
where		r.RID = @RestaurantID

if @ResDateTime < @realtime
	RaisError ('104',16,1)
	
GO

GRANT EXECUTE ON [XML_CheckResoTime] TO ExecuteOnlyRole

GO
