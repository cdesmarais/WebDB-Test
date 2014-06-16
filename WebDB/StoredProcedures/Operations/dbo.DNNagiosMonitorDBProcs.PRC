if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosMonitorDBProcs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosMonitorDBProcs]
GO

CREATE Procedure dbo.DNNagiosMonitorDBProcs
As

	select * 
	from NagiosDBMonitorProcs
	where active = 1
	order by SortOrder
GO

GRANT EXECUTE ON [DNNagiosMonitorDBProcs] TO ExecuteOnlyRole
GRANT EXECUTE ON [DNNagiosMonitorDBProcs] TO MonitorUser
GO
