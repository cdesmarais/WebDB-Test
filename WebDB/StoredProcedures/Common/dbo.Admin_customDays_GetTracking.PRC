
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_customDays_GetTracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_customDays_GetTracking]
GO




CREATE PROCEDURE dbo.Admin_customDays_GetTracking

@Restaurant_ID int

As
SET NOCOUNT ON



Select RID,customAction,Days,DateChanged,UserID
from customedDayTrack
where rid = @Restaurant_ID
order by DateChanged

GO

GRANT EXECUTE ON [Admin_customDays_GetTracking] TO ExecuteOnlyRole

GO
