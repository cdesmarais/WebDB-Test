
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetcustomedDayInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetcustomedDayInfo]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetcustomedDayInfo
(
  @RID int,
  @customedDate datetime
)
AS

-- return customed day information for restaurant..
SELECT		COALESCE(b.Message,'') as Message, 
			customedBy, 
			customedDate,
			r.RName as RestaurantName, 
			Datecustomed, 
			MetroareaName, 
			h.holidayid,
			holidaydate, 
			h.countryid, 
			override
FROM		RestaurantVW r
left join	customedDayVW b 
on			r.rid = b.rid 
AND			customedDate = @customedDate
inner join	holidayschedule h 
on			(h.countryid = r.country or h.countryid = 'ALL')
inner join	holidays hol 
on			hol.holidayid = h.holidayid
inner join	neighborhood n 
on			r.neighborhoodID = n.neighborhoodID
inner join	MetroareaAVW m 
on			m.MetroareaID = n.MetroareaID
and			m.LanguageID = r.LanguageID
WHERE		r.RID = @RID

GO


GRANT EXECUTE ON [Admin_Restaurant_GetcustomedDayInfo] TO ExecuteOnlyRole

GO
