GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_BlockDays_GetTracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_BlockDays_GetTracking]
GO


CREATE PROCEDURE dbo.Admin_BlockDays_GetTracking

@Restaurant_ID int

As
SET NOCOUNT ON



Select RID,BlockAction,Days,DateChanged,UserID,BlockedDayReason.BlockReason
from BlockedDayTrack
left outer join BlockedDayReason on BlockedDayTrack.BlockReason = BlockedDayReason.reasonID
where rid = @Restaurant_ID
order by DateChanged

GO


GRANT EXECUTE ON [Admin_BlockDays_GetTracking] TO ExecuteOnlyRole

GO
