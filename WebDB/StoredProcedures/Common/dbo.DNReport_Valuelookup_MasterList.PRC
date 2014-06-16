if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReport_Valuelookup_MasterList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[DNReport_Valuelookup_MasterList]
GO

create procedure dbo.DNReport_Valuelookup_MasterList
as

	set transaction isolation level read uncommitted
	set nocount on

	select		LookupID
				,[Type]
				,[Key]
				,Description
				,ForeignKey
	from 		valuelookupmaster 
	order by 	[key] asc

GO

GRANT EXECUTE ON [DNReport_Valuelookup_MasterList] TO ExecuteOnlyRole
GO

