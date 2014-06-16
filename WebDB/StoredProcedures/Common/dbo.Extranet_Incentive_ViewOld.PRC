if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ViewOld]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ViewOld]
GO

CREATE PROCEDURE dbo.Extranet_Incentive_ViewOld

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

select distinct(Incentive.RID) as restaurant_id,r.Rname as name,m.MetroAreaName as city 
from Incentive 
inner join	RestaurantVW r 
on			r.RID = Incentive.RID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageId
inner join	MetroAreaAVW m
on			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
where		Incentive.Enddate < getdate()
and			Incentive.LastMinutePopThresholdTime IS NULL
Order By r.RName

GO

GRANT EXECUTE ON [Extranet_Incentive_ViewOld] TO ExecuteOnlyRole

GO
