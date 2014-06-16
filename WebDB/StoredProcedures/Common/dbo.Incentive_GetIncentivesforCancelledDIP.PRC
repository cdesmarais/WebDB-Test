if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetIncentivesforCancelledDIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetIncentivesforCancelledDIP]
GO

CREATE procedure [dbo].[Incentive_GetIncentivesforCancelledDIP]
(
@RID int
)
AS

select 
			i.RID as rid
			,r.RName as rname
			,i.incentiveid as incentive_id
			,i.IncentiveName as incentivename 
			,ds.DSchName as incentiveday
			,ds.DSchID as IncentiveDayID
			,i.Startdate as startdate
			,i.createdate as createdate
			,i.Enddate as enddate
			,i.StartTime as starttime
			,i.EndTime as endtime
			,datedisabled as datedisabled
			,convert(int,i.active) as IncentiveStatus
			,i.Startdate +  i.StartTime as incentivestart
			,i.Enddate + i.EndTime as incentiveend
			,i.ActiveIncHistID
from		Incentive i
inner join	DaySchedule ds
on			i.IncentiveDay = ds.DSchID
inner join	RestaurantVW r 
on			i.RID = r.RID
and			r.RestStateID = 1
where		i.Active= 1 
and			i.RID = @RID
order by	r.RName
			,i.StartTime
			,i.Startdate
			,i.incentiveid

Go

GRANT EXECUTE ON [Incentive_GetIncentivesforCancelledDIP] TO ExecuteOnlyRole

GO

