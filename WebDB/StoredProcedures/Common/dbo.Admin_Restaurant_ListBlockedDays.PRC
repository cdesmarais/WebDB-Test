if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ListBlockedDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ListBlockedDays]
GO



CREATE PROCEDURE dbo.Admin_Restaurant_ListBlockedDays
 (
  @GeoID int,
  @date datetime
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,bd.BlockedDate as Blocked_Date
			,bd.Message
			,MetroareaName
			,r.RSName
From		RestaurantVW r
Inner Join	Neighborhood n 
On			r.neighborhoodid = n.neighborhoodid
Inner Join	MetroareaAVW m 
On			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
left join	BlockedDayVW bd
on			r.RID = bd.RID 
and			bd.BlockedDate = @date
where		n.metroareaid = @GeoID
ORDER BY	r.RSName, r.RName Asc



GO


GRANT EXECUTE ON [Admin_Restaurant_ListBlockedDays] TO ExecuteOnlyRole

GO
