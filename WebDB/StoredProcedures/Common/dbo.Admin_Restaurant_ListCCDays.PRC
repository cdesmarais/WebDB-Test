if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ListCCDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ListCCDays]
GO



CREATE PROCEDURE dbo.Admin_Restaurant_ListCCDays
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
			,bd.PartySize as Party_Size
			,MetroareaName
			,bd.CCDayID
From		RestaurantVW r
Inner Join	Neighborhood n 
On			r.neighborhoodid = n.neighborhoodid
Inner Join	MetroareaAVW m 
On			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
left join	CreditCardDayVW bd
on			r.RID = bd.RID 
and			bd.BlockedDate = @date
where		n.metroareaid = @GeoID
and			r.Allotment = 0 /* Allotment restaurants do not support credit card */
ORDER BY	r.RSName ASC, r.RName Asc

GO

GRANT EXECUTE ON [Admin_Restaurant_ListCCDays] TO ExecuteOnlyRole

GO
