if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromotedOfferApi_GetTimezoneByRid]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromotedOfferApi_GetTimezoneByRid]
GO

CREATE PROCEDURE dbo.PromotedOfferApi_GetTimezoneByRid
	@RID int
As

SET NOCOUNT ON
set transaction isolation level read uncommitted  

select 
	tz.TZID, 
	tz.TZName
from TimeZone tz
join Restaurant r
on tz.TZID = r.TZID
where r.RID = @RID

GO

GRANT EXECUTE ON [PromotedOfferApi_GetTimezoneByRid] TO ExecuteOnlyRole

GO