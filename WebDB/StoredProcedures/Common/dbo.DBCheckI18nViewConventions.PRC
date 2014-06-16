if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nViewConventions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nViewConventions]
GO

CREATE Procedure dbo.DBCheckI18nViewConventions
 
As

--Case: Ensure LanguageId used in correct situation; All AVW should use languageID

create table #tables
(
TableName varchar(200),
ColName varchar(200)
)

create table #Exceptions
(
ProcName varchar(200),
Reason varchar(2000)
)

SET NOCOUNT ON
--Tables that must be used with a LanguageID

insert into #tables values ('errorMessage', 'LanguageID')
insert into #tables values ('FoodType', 'LanguageID')
insert into #tables values ('DefaultMessage', 'LanguageID')
insert into #tables values ('EmailTemplateDetails', 'LanguageID')
insert into #tables values ('EmailTemplateElements', 'LanguageID')
insert into #tables values ('EmailTemplateDetailsChangeLog', 'LanguageID')
insert into #tables values ('RestaurantCustomMessage', 'LanguageID')

insert into #tables (TableName,ColName)
Select distinct	object_name(depid) as TableName,
		'LanguageID' as ColName
from		sysdepends
WHERE object_name(depid) LIKE '%local' OR object_name(depid) LIKE '%AVW' COLLATE sql_latin1_general_cp1_cs_as


insert into #Exceptions values ('Admin_MacroAdd', 'OK: Proc looks for existence of name in any language')
insert into #Exceptions values ('Admin_FoodType_Get', 'OK: Proc takes an ID which is already restricted by LanguageID')
insert into #Exceptions values ('Cuisine_FoodType_Update', 'OK: Proc takes an ID which is already restricted by LanguageID')
insert into #Exceptions values ('Cuisine_GetCuisineInfo', 'OK: Proc takes an ID which is already restricted by LanguageID')
insert into #Exceptions values ('Cuisine_GetSearchableCuisine', 'OK: Proc takes an ID which is already restricted by LanguageID')
insert into #Exceptions values ('Admin_FoodType_Update', 'OK: Proc takes an ID which is already restricted by LanguageID')
insert into #Exceptions values ('Admin_customDays_Delete', 'OK: Proc deletes all Languages associated to the ID')
insert into #Exceptions values ('Admin_CCDays_Delete_byID', 'OK: Proc deletes all Languages associated to the ID')
insert into #Exceptions values ('errorMessage', 'OK: _key computed column references the errormessage table; this is okay')
insert into #Exceptions values ('DNGetErrorList', 'OK: Proc Should be obsoleted after i18n')
insert into #Exceptions values ('XML_ErrorStringGetByLanguageID', 'OK: Proc likely never called; works without LanguageID')
insert into #Exceptions values ('Errors_GetByLanguageID', 'OK: Proc likely never called; works without LanguageID')
insert into #Exceptions values ('Admin_CCDays_Delete', 'OK: Proc Deletes day and all local info associated to it')
insert into #Exceptions values ('Delete_MacroNeighborhood', 'OK: Deletes all Languages')
insert into #Exceptions values ('Delete_Metro', 'OK: Deletes all Languages')
insert into #Exceptions values ('Delete_Neighborhood', 'OK: Deletes all Languages')
insert into #Exceptions values ('Delete_Restaurant', 'OK: Deletes all Languages')
insert into #Exceptions values ('Delete_Holiday', 'OK: Deletes all Languages')




select		object_name(depid) [Table Name], 
			object_name(id) ProcName, 
			col_name(depid, depnumber) ColName,
			IsNull(e.Reason, 'Proc must reference LanguageID for specified table or view.') [Explanation]
from		sysdepends
inner join	#tables t
on			object_name(depid) = t.tablename
left join (
	-- Set of Procs that correctly reference required fields
	select		distinct object_name(depid) tname, 
				object_name(id) ProcName 
	from		sysdepends
	inner join	#tables t
	on			object_name(depid) = t.tablename
				and col_name(depid, depnumber) = t.ColName
) tl
on			object_name(depid) = tl.tname
and			object_name(id) = tl.ProcName
left join	#Exceptions e
on			e.ProcName = object_name(id)
where		tl.tname is null 
ORDER BY	[Explanation] desc,  object_name(id)

drop table #tables
drop table #Exceptions

go

GRANT EXECUTE ON [DBCheckI18nViewConventions] TO ExecuteOnlyRole

GO
