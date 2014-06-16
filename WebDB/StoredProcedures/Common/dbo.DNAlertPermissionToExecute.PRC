if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAlertPermissionToExecute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAlertPermissionToExecute]
GO



CREATE PROCEDURE dbo.DNAlertPermissionToExecute

AS

Declare @procs nvarchar(4000)
Set @procs = ''
Declare @DateMade datetime
Set @DateMade = current_timestamp


SELECT @procs = @procs + '<br>' + SYSOBJECTS.NAME 
FROM SYSOBJECTS 
left outer join syspermissions
on				sysobjects.id = syspermissions.id 
left outer join sysusers
on				sysusers.uid = syspermissions.grantee 
and				sysusers.name = 'ExecuteOnlyRole'
where syspermissions.id is null
and TYPE = 'P' 
AND LEFT(SYSOBJECTS.NAME,2) <> 'sp' -- system procs 
AND LEFT(SYSOBJECTS.NAME,2) <> 'dt' -- VSS procs
AND LEFT(SYSOBJECTS.NAME,2) <> 'cs' -- Cache Server procs
AND LEFT(SYSOBJECTS.NAME,2) <> 'rs' -- RIMS server procs
order by SYSOBJECTS.NAME


if @procs <> ''
BEGIN
	Set @procs = 'The following do not have the permission to Execute ' + @procs
	Exec dbo.DNNagiosWriteStatus @NagiosTaskID = 3, 
		@Host = null, 
		@Status = 2, 
		@UpdateDT = @DateMade, 
		@Msg = @procs
END
else
BEGIN
	Exec dbo.DNNagiosWriteStatus @NagiosTaskID = 3, 
		@Host = null, 
		@Status = 0, 
		@UpdateDT = @DateMade, 
		@Msg = 'Stored Procs OK'
END	

GO

GRANT EXECUTE ON [DNAlertPermissionToExecute] TO ExecuteOnlyRole

GO
