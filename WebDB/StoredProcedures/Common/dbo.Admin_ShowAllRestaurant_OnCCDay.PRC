if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ShowAllRestaurant_OnCCDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ShowAllRestaurant_OnCCDay]
GO


CREATE PROCEDURE dbo.Admin_ShowAllRestaurant_OnCCDay
 (  
  @date datetime
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		r.RName AS RestaurantName,
			r.RID AS RestaurantID
			,MetroareaName AS Metro
			,r.RSName
			,r.DomainID
From		RestaurantVW r
Inner Join	Neighborhood n 
On			r.neighborhoodid = n.neighborhoodid
Inner Join	MetroareaAVW m 
On			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
inner join	CreditCardDayVW bd
on			r.RID = bd.RID 
WHERE		bd.BlockedDate = @date
and			r.Allotment = 0 /* Allotment restaurants do not support credit card */
ORDER BY	MetroAreaName, r.RSName Asc, r.RName Asc


GO


GRANT EXECUTE ON [Admin_ShowAllRestaurant_OnCCDay] TO ExecuteOnlyRole

GO

