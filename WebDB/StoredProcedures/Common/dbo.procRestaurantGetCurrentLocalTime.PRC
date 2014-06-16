if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procRestaurantGetCurrentLocalTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procRestaurantGetCurrentLocalTime]
GO



CREATE PROCEDURE dbo.procRestaurantGetCurrentLocalTime
(
@RID int,
@localTime datetime OUTPUT
)
AS

--******************************************
--** This procedure is a helper proc to retrieve the current local time for a restaurant
--** NOTE: To get values for more than 1 restaurant directly join with the TimeZoneVW
--******************************************

SET NOCOUNT ON


select @localTime = currentLocalTime 
from restaurant r 
inner join TimezoneVW t on r.TZID = t.TZID
where RID = @RID

GO

GRANT EXECUTE ON [procRestaurantGetCurrentLocalTime] TO ExecuteOnlyRole

GO
