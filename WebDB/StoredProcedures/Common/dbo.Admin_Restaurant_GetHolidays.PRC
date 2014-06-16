
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetHolidays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetHolidays]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetHolidays
(
  @RID int
)
AS


SELECT	r.RName as RestaurantName, 
		MetroareaName, 
		h.holidayid,
		holidaydate, 
		h.countryid, 
		override
FROM		RestaurantAVW r
INNER JOIN	holidayschedule h 
ON			(h.countryid = r.country or h.countryid = 'ALL') AND [HolidayDate] > GETDATE()
INNER JOIN	holidays hol 
ON			hol.holidayid = h.holidayid
INNER JOIN	neighborhood n 
ON			r.neighborhoodID = n.neighborhoodID
INNER JOIN	MetroareaVW m 
ON			m.MetroareaID = n.MetroareaID
inner join	dbo.DBUserDistinctLanguageVW db 
on			db.languageid = r.LanguageID
WHERE		r.RID = @RID


GO


GRANT EXECUTE ON [Admin_Restaurant_GetHolidays] TO ExecuteOnlyRole

GO
