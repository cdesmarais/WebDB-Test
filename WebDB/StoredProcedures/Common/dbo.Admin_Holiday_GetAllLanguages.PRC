if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_GetAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_GetAllLanguages]
GO


CREATE PROCEDURE dbo.Admin_Holiday_GetAllLanguages
(
  @Holiday_ID int = 0
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		DISTINCT(h.HolidayName) as Name
		,l.languageID as LanguageID
		,l.LanguageRegionDesc as LanguageName
from		HolidaySchedule
inner join	HolidayAVW h
on		h.HolidayID = HolidaySchedule.HolidayID
INNER JOIN	Language l
on		h.languageID = l.LanguageID
where		h.HolidayID = @Holiday_ID 
and		HolidayDate > current_timestamp-1

GO

GRANT EXECUTE ON [Admin_Holiday_GetAllLanguages] TO ExecuteOnlyRole

GO
