if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosMonitorCacheServerHeartBeat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosMonitorCacheServerHeartBeat]
GO

CREATE Procedure dbo.DNNagiosMonitorCacheServerHeartBeat
As



declare @MaxDT datetime
set @MaxDT = dateadd(mi, -1, getdate())

--GroupData	NagiosHost	NagiosService	Expired	Status	UpdateDT	Msg
select	n.GroupData,
	n.GroupCount,
	n.NagiosHost NagiosHost,
	isnull(n.NagiosTask, nt.Task) NagiosService,
	t.*,
	(case when datediff(mi, @MaxDT, UpdateDT) > nt.LeaseMi then 1 else 0 end) Expired,
	(case when HBsLogged = 10 then 0 -- Got All Ten
		when HBsLogged = 9 and 	datediff(mi, UpdateDT, @MaxDT) > 1 then 1 -- Didn't match expectation (based on timing;  report on it next iteration)
		else 2  -- Fail
	end) Status,
	('Last Run:' + IsNull(cast(UpdateDT as nvarchar(17)), 'No Data')
				+ ' Status:' + (case when HBsLogged != HBsExpected then '2' -- Didn't meet expectation
						when HBsLogged != 10 then '1' -- Didn't match expectation (this might be okay)
						else '0'  -- Everyhtng matched
						end) 
				+ ' Expired:' + (case when datediff(mi, @MaxDT, UpdateDT) > nt.LeaseMi then '1' else '0' end)
				+ ' Heartbeats For Past 10 minutes: ' + cast(HBsLogged as nvarchar(10))
	) Msg
from (
select IsNull(count(distinct datepart(mi, errtimestamp)),0) HBsLogged,  -- Count distinct minutes (CS will sometimes send more than 1 per mi)
       IsNull(datediff(mi, min(errtimestamp), max(errtimestamp)) + 1,0) HBsExpected,
	min(errtimestamp) MinDT,
 	IsNull(max(errtimestamp), '1990-01-01') UpdateDT
from ErrorLogVW
where errorlogid > (select max(errorlogid) - 10000 from ErrorLogVW)
and errorid = 7100
and errmsg not like '%Continue%'
and errtimestamp >= dateadd(mi, -10, @MaxDT) and  errtimestamp < @MaxDT
) t
inner join NagiosTask nt on NagiosTaskID = 5 -- Single entry in NagiosTask table
inner join NagiosTaskType n on n.type = nt.NagiosTaskType  

GO

GRANT EXECUTE ON [DNNagiosMonitorCacheServerHeartBeat] TO ExecuteOnlyRole
GRANT EXECUTE ON [DNNagiosMonitorCacheServerHeartBeat] TO MonitorUser

GO


