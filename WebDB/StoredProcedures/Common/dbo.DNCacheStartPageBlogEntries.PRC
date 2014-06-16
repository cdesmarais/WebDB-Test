if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStartPageBlogEntries]') and objectproperty(id, N'IsProcedure') = 1)
drop procedure [dbo].DNCacheStartPageBlogEntries
go

--Create the stored procedure to fetch the blog data for caching
create procedure dbo.DNCacheStartPageBlogEntries
as  
  
set transaction isolation level read uncommitted  
set nocount on  
   
select
	EntryId
	,ProcessedDateUTC
	,IsParent
	,Title
	,Url
	,PublishDateUTC
	,Description
from StartPageBlogEntries  
go

grant execute on [dbo].DNCacheStartPageBlogEntries TO ExecuteOnlyRole
go
