if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNPromoPagesGetRules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNPromoPagesGetRules]
GO

CREATE PROCEDURE dbo.DNPromoPagesGetRules
AS

set transaction isolation level read uncommitted

Select Distinct 	PromoPages.PromoID, 
					EventStartDate, 
					EventEndDate, 
					SuppressDIP, 
					coalesce(QualifyConfMessage,'') as QualifyConfMessage, 
					coalesce(NonQualifyConfMessage,'') as NonQualifyConfMessage, 
					coalesce(ExclusionDate,getdate()-1) as ExclusionDate, 
					RegionID, 
					ExclusionMessage,
					DisplaySearchBoxExclusion
from				PromoPages 
left join			PromoPageExclusions 
on					PromoPages.PromoID = PromoPageExclusions.PromoID
left join			PromoPagesToRegion 
on					PromoPages.PromoID = PromoPagesToRegion.PromoID
left join 			PromoPagesToMetro PPTM on PromoPages.PromoID = PPTM.PromoID
left join 			MetroArea ma on ma.MetroAreaID = PPTM.MetroID
inner join 			TimeZoneVW tz on tz.TZID = coalesce(ma.TZID,4) -- default to PST if no metro for a promo
inner join			dbo.DBUserDistinctLanguageVW db on db.languageid = PromoPages.LanguageID

where 
					PromoPages.active = 1 
and 				EventEndDate > tz.currentLocalTime
and 				(SuppressDIP = 1 or coalesce(QualifyConfMessage,'') != '' or coalesce(NonQualifyConfMessage,'') != '' or coalesce(ExclusionMessage,'') != '')
order by 			PromoPages.PromoID, ExclusionDate, RegionID

GO
GRANT EXECUTE ON [DNPromoPagesGetRules] TO ExecuteOnlyRole

GO
