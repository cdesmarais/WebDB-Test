if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReport_Valuelookup_MasterList_Values]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[DNReport_Valuelookup_MasterList_Values]
GO

create procedure dbo.DNReport_Valuelookup_MasterList_Values
(
	@LookupID int
)
as

	set transaction isolation level read uncommitted
	set nocount on

	select		valueid 
	from 		valuelookupidlist 
	where 		lookupid=@LookupID 
	order by 	valueid asc

GO

GRANT EXECUTE ON [DNReport_Valuelookup_MasterList_Values] TO ExecuteOnlyRole

GO
