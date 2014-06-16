
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetMessagetStartEndDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetMessagetStartEndDates]
GO


CREATE PROCEDURE [dbo].[Admin_Restaurant_GetMessagetStartEndDates]
 (
  @RID int
 )

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


select 	MessageTypeID, 
		StartDate as SpecialEventStartDate, 
		EndDate as SpecialEventEndDate
from 	RestaurantCustomMessage rcm
inner 	join [RestaurantVW] r 
ON 		rcm.[RID] = r.[RID]
where	rcm.RID = @RID
AND		MessageTypeID = 58
AND		rcm.LanguageID = r.LanguageID


GO

GRANT EXECUTE ON [Admin_Restaurant_GetMessagetStartEndDates] TO ExecuteOnlyRole

GO
