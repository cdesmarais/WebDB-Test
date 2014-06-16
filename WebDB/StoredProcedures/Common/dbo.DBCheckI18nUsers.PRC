if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nUsers]
GO

CREATE Procedure dbo.DBCheckI18nUsers
 
As

--********************
--** Verify correct users are in the DBUser Table
--********************

--***********************
--** Exceptions: Procs that are allowed to reference obsolte columns
--***********************
create table #Exceptions
(
Name varchar(200) collate database_default,
Reason varchar(2000) collate database_default
)

insert into #Exceptions values ('WebEUInstall', 'OK: This is a temporary account; will be deted soon')
insert into #Exceptions values ('WebWrite', 'OK: This is only OK in non-Production environments')


select		DBUser [DBUSer Table], 
			su.name [DB System User],
			IsNull(e.Reason, 'NOT OK:User does not exist in the DBUser table. Add User to DBUser table') [Explanation]
from		sysUsers su
left join	DBUser db
on			db.DBUser = su.name	  
left join	#Exceptions e
on			e.Name = su.name
where		dbuser is NULL AND su.NAME LIKE 'Web%'
and			status = 2


GO



GRANT EXECUTE ON [DBCheckI18nUsers] TO ExecuteOnlyRole

GO
