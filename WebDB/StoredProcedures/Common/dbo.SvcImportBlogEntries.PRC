-- Must drop proc before dropping the type
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcImportBlogEntries]') and objectproperty(id, N'IsProcedure') = 1)
drop procedure [dbo].SvcImportBlogEntries
go

-- Drop type after reference is removed
if exists(select * from sys.types where name = 'BlogEntriesImportType' and is_table_type = 1)
drop type dbo.BlogEntriesImportType
go



--Create the DB type to pass in to the stored procedure
create type [dbo].[BlogEntriesImportType] as table(
	[IsParent] [bit] not null,
	[Title] [nvarchar](200) not null,
	[Url] [nvarchar](200) not null,
	[PublishDateUTC] [datetime] not null,
	[Description] [nvarchar](800) not null
)
go

grant execute on type::dbo.BlogEntriesImportType to ExecuteOnlyRole
go


--Create the stored procedure to process and store the blog entries
create procedure dbo.SvcImportBlogEntries  
(  
 @RssDataSet dbo.BlogEntriesImportType readonly  
)  
as  
  
set nocount on  
set transaction isolation level read uncommitted   
  
declare @Action as nvarchar(3000)  
  
begin transaction
  
--Clear out the previous start page blog entries
set @Action = 'Clearing out existing start page blog entries'  
delete StartPageBlogEntries
  
If @@error <> 0   
	goto general_error  
  
--Add the new entries
set @Action = 'Adding new entries to the StartPageBlogEntries table'  
insert into StartPageBlogEntries   
(  
	IsParent  
	,Title
	,Url
	,PublishDateUTC
	,Description
)
select
	IsParent  
	,Title
	,Url
	,PublishDateUTC
	,Description
from @RssDataSet
  
if @@error <> 0   
	goto general_error  
  
commit transaction  
return(0)  
  
general_error:  
begin  
	rollback transaction  
   
	raiserror (@Action,16,1)  
   
	return(-1)  
end
go

grant execute on [dbo].SvcImportBlogEntries to ExecuteOnlyRole
go
