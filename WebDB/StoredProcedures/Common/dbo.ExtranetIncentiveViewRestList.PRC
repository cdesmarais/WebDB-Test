if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtranetIncentiveViewRestList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtranetIncentiveViewRestList]
GO

CREATE PROCEDURE dbo.ExtranetIncentiveViewRestList
(
  @Metro_ID int
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

select distinct r.RID as restaurant_ID
				,r.RName as name,DSchID as schedule_ID
				,CASE WHEN ((r.RestStateID = 1 AND r.IsReachable = 1) or (r.Allotment = 1) AND(r.RestStateID = 1))
					THEN 1 ELSE 0 END AS RestaurantState
from		DaySchedule
inner join	Incentive 
on			DaySchedule.DSchID = Incentive.IncentiveDay
inner join	RestaurantVW r
on			r.RID = Incentive.RID
inner join	Neighborhood n 
on			n.neighborhoodid = r.neighborhoodid
where		DSchID in (1,2,3,4,5,6,7) 
and			n.metroareaid = @Metro_ID 
and			Incentive.active = 1 
and			Incentive.LastMinutePopThresholdTime IS NULL
and			Enddate >= getdate()-1
and			r.RestStateID in (1,5,6,13)
Order By	r.RName
			,r.RID desc
			,DSchID

GO

GRANT EXECUTE ON [ExtranetIncentiveViewRestList] TO ExecuteOnlyRole

GO
