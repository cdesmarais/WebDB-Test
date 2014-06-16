if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReport_Valuelookup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[DNReport_Valuelookup]
GO

create procedure dbo.DNReport_Valuelookup
as
	set transaction isolation level read uncommitted
	set nocount on

	select 		ltype
				,lkey
				,valueint
				,valuedt
				,valuechar
	from		valuelookup 
	order by 	ltype, lkey asc

GO

GRANT EXECUTE ON [DNReport_Valuelookup] TO ExecuteOnlyRole
GO

