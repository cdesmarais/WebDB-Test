if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ViewAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ViewAll]
GO

CREATE PROCEDURE dbo.Extranet_Incentive_ViewAll
(
  @Metro_ID int = 4
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select	distinct(Incentive.RID) as restaurant_id,
			r.Rname as name,
			m.MetroAreaName as city,
			StartTime as Start_Time,
			EndTime as End_Time
from		Incentive 
inner join	RestaurantVW r 
on			r.RID = Incentive.RID
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner join	MetroAreaAVW m 
on			m.metroareaid = n.metroareaid
and			m.LanguageID = r.LanguageID
where		Incentive.active = 1
and			Incentive.LastMinutePopThresholdTime IS NULL
and			Enddate >= getdate()-1 
and			n.metroareaid = @Metro_ID
Order By	r.RName
			,StartTime

GO

GRANT EXECUTE ON [Extranet_Incentive_ViewAll] TO ExecuteOnlyRole

GO
