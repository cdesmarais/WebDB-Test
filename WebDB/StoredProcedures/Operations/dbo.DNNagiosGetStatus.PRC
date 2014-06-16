if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosGetStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosGetStatus]
GO

CREATE Procedure dbo.DNNagiosGetStatus
As

Select GroupData,
	GroupCount,
	IsNull(NagiosHost, Host) NagiosHost,
	IsNull(NagiosTask, Task) NagiosService,
	(Case when datediff(mi, UpdateDT, GetDate()) > LeaseMi 
		then 1 else 0 end) Expired,
	Status,
	UpdateDT,
	(case when GroupData = 1 then Task + ': ' + msg
		Else Msg end) Msg,
	Host,
	Task TaskName
from NagiosTask nt
Inner join NagiosTaskType ntt 
	on nt.NagiosTaskType = ntt.type
inner join NagiosTaskStatus nts
	on nts.NagiosTaskID = nt.NagiosTaskID
order by GroupData, NagiosHost, NagiosService

GO
  GRANT EXECUTE ON [DNNagiosGetStatus] TO ExecuteOnlyRole
  GRANT EXECUTE ON [DNNagiosGetStatus] TO MonitorUser


go
