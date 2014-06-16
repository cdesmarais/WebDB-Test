if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetCCDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetCCDay]
GO


CREATE PROCEDURE dbo.Admin_Restaurant_GetCCDay
(
  @RID int,
  @BlockedDate datetime
)
AS



SELECT		
		coalesce(b.Message,'') as Message,
		BlockedBy as BlockedBy, 
		BlockedDate as BlockedDate,
		r.RName as RestaurantName,
		coalesce(DateBlocked,'') as DateBlocked, 
		MetroareaName,
		[Language].[LanguageID], 
		[LanguageCode], 
		[LanguageRegionDesc],
		r.LanguageID as RestaurantLanguage,
		dm.Message as DefaultMessage,
		PartySize,
		StartTime,
		EndTime
FROM		RestaurantAVW r
inner join	neighborhoodAVW n 
on			n.neighborhoodID = r.neighborhoodID
and			n.LanguageID = r.LanguageID
inner join	MetroareaLocal m 
on			m.MetroareaID = n.MetroareaID
and			m.LanguageID = r.LanguageID
INNER JOIN	[Language] 
ON			r.[LanguageID] = [Language].[LanguageID]
INNER JOIN	[DefaultMessage] dm
ON			dm.[LanguageID] = r.[LanguageID]
AND			MessageTypeID = 11
LEFT OUTER JOIN	CreditCardDayAVW b 
ON			b.RID = r.RID
AND			b.[LanguageID] = r.LanguageID
AND			BlockedDate = @BlockedDate

WHERE			[Language].[Active] = 1
AND			r.RID = @RID
ORDER BY [Language].[LanguageID]


GO


GRANT EXECUTE ON [Admin_Restaurant_GetCCDay] TO ExecuteOnlyRole

GO

