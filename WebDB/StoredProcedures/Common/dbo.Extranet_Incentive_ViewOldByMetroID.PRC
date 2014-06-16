if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ViewOldByMetroID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ViewOldByMetroID]
GO

CREATE PROCEDURE dbo.Extranet_Incentive_ViewOldByMetroID

@MetroID int

AS
SET NOCOUNT ON

select		distinct(Incentive.RID) as restaurant_id,
			r.Rname as name,
			m.MetroAreaName as city 
from		Incentive 
inner join	RestaurantVW r 
on			r.RID = Incentive.RID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner join	MetroAreaAVW m
on			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
where		Incentive.Enddate < getdate()
and			Incentive.LastMinutePopThresholdTime IS NULL
and			m.metroareaid = @MetroID
Order By	r.RName
GO

GRANT EXECUTE ON [Extranet_Incentive_ViewOldByMetroID] TO ExecuteOnlyRole

GO
