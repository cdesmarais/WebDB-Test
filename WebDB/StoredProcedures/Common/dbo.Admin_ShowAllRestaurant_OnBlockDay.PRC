if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ShowAllRestaurant_OnBlockDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ShowAllRestaurant_OnBlockDay]
GO


CREATE PROCEDURE dbo.Admin_ShowAllRestaurant_OnBlockDay
 (  
  @date datetime
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		r.RName AS RestaurantName,
			r.RID AS RestaurantID
			,MetroareaName AS Metro
			,bdr.BlockReason AS Reason
			,r.RSName
			,r.DomainID
From		RestaurantVW r
Inner Join	Neighborhood n 
On			r.neighborhoodid = n.neighborhoodid
Inner Join	MetroareaAVW m 
On			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
inner join	BlockedDay bd
on			r.RID = bd.RID 
inner join BlockedDayReason bdr
on			bd.BlockReason = bdr.ReasonID
and			bd.BlockedDate = @date
ORDER BY	MetroAreaName, r.RSName Asc, r.RName Asc


GO


GRANT EXECUTE ON [Admin_ShowAllRestaurant_OnBlockDay] TO ExecuteOnlyRole

GO

