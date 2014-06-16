if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGrantPermissions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGrantPermissions]
GO

GO

CREATE PROCEDURE dbo.procGrantPermissions AS

/* ------------------------------------------------------------
PROCEDURE: procGrantPermissions 

DESCRIPTION: Grants Execute permissions on all procs in database
for Login  

------------------------------------------------------------ */
	
	DECLARE @ExecSQL nvarchar(100)
	
	DECLARE curGrants CURSOR FOR
	
	
	SELECT 	'GRANT EXECUTE ON [' + SYSOBJECTS.NAME + '] TO CharmUser' -- Replace MyLogin with the name of your new Login 
	FROM 	SYSOBJECTS 
	left 	outer join 	syspermissions
	on 			sysobjects.id =
				syspermissions.id 
	left 	outer join 	sysusers
	on 			sysusers.uid = syspermissions.grantee 
				and sysusers.name = 'charmuser'
	where 			syspermissions.id is null
	and 	TYPE = 'P' 
	AND 	LEFT(SYSOBJECTS.NAME,2) <> 'sp' -- system procs 
	AND 	LEFT(SYSOBJECTS.NAME,2) <> 'dt' -- VSS procs
	
	
	OPEN curGrants
	
	FETCH NEXT FROM curGrants
	
	INTO @ExecSQL
	
	
	WHILE @@FETCH_STATUS = 0
	
	BEGIN -- this will loop thru all your own procs and grant Execute privileges on each one
	
		Exec(@ExecSQL)
		IF @@ERROR <> 0
		BEGIN
			exec DNErrorAdd 126, 'procGrantPermissions:Error adding Permissions', @ExecSQL, 2
		END 
		
		exec DNErrorAdd 126, 'procGrantPermissions:Need to grant permissions', @ExecSQL, 2

		FETCH NEXT FROM curGrants INTO @ExecSQL
		
	END
	
	CLOSE curGrants
	DEALLOCATE curGrants
GO

GRANT EXECUTE ON [procGrantPermissions] TO ExecuteOnlyRole

GO
