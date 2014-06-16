if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetByMetroID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetByMetroID]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetByMetroID
 (
  @Metro_Area_ID int
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		r.RName as name
			,m.MetroAreaName as city
			,r.RID as restaurant_id
			,e.ServerIP as server_ip
			,e.serverPwd as password
			,r.AcceptCheque as Accept_Cheque
FROM		RestaurantVW r
inner join	ERBRestaurant e
on			e.RID = r.RID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid 
and			n.LanguageID = r.LanguageID
inner join	MetroAreaLocal m
on			m.metroareaid = n.metroareaid 
and			m.LanguageID = r.LanguageID
WHERE		m.metroareaid = @Metro_Area_ID
order by	r.RName asc
GO

GRANT EXECUTE ON [Admin_Restaurant_GetByMetroID] TO ExecuteOnlyRole

GO
