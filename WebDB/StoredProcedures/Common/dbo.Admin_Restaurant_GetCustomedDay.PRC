
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetCustomedDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetCustomedDay]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetCustomedDay
(
  @RID int,
  @customedDate datetime
)
AS



SELECT		
		coalesce(Message,'') as Message,
		coalesce(customedBy,'') as customedBy, 
		coalesce(customedDate,'') as customedDate,
		coalesce(Datecustomed,'') as Datecustomed, 
		[Language].[LanguageID], 
		[LanguageCode], 
		[LanguageRegionDesc],
		r.LanguageID as RestaurantLanguage,
		r.RName as RestaurantName,
	    cd.DetailsPageOnly

FROM		RestaurantAVW r
LEFT OUTER JOIN	CustomedDayAVW cd 
ON			cd.RID = r.RID
AND			cd.[LanguageID] = r.LanguageID
AND			cd.customedDate = @customedDate
INNER JOIN	[Language] 
ON			r.[LanguageID] = [Language].[LanguageID]
WHERE		[Language].[Active] = 1
AND			r.RID = @RID
ORDER BY [Language].[LanguageID]


GO


GRANT EXECUTE ON [Admin_Restaurant_GetCustomedDay] TO ExecuteOnlyRole

GO
