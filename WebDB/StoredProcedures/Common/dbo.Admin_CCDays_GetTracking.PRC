
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CCDays_GetTracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CCDays_GetTracking]
GO




CREATE PROCEDURE dbo.Admin_CCDays_GetTracking

@Restaurant_ID int

As
SET NOCOUNT ON



Select RID
	,customAction
	,Days
	,coalesce(StartTime, '12:00 AM') as StartTime
	,coalesce(EndTime, '11:59 PM') as EndTime
	,DateChanged
	,UserID
from CCDayTrack
where rid = @Restaurant_ID
order by DateChanged

GO

GRANT EXECUTE ON [Admin_CCDays_GetTracking] TO ExecuteOnlyRole

GO
