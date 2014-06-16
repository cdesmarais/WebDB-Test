
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ListcustomedDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ListcustomedDays]
GO


CREATE PROCEDURE dbo.Admin_Restaurant_ListcustomedDays
 (
  @GeoID int,
  @date datetime
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,bd.customedDate as customed_Date
			,bd.Message
			,MetroareaName
			,r.RSName
From		RestaurantVW r
Inner Join	NeighborhoodAVW n 
On			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
Inner Join	MetroareaAVW m 
On			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
left join	customedDayVW bd
on			r.RID = bd.RID 
and			bd.customedDate = @date
where		n.metroareaid = @GeoID
ORDER BY	r.RSName Asc, r.RName Asc

GO


GRANT EXECUTE ON [Admin_Restaurant_ListcustomedDays] TO ExecuteOnlyRole

GO
