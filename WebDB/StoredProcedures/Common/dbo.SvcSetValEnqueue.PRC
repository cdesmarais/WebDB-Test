

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcSetValEnqueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcSetValEnqueue]
go

create procedure dbo.SvcSetValEnqueue
(
	@parRID  int
	,@parKey nvarchar(500)
	,@parVal nvarchar(500)
	,@parReason nvarchar(500)
)

as  
/* Stored procedure used to insert in SetValQueue table. */

insert into
	SetValQueue
	(
		[RID]
		,[key]
		,[Val]
		,[Reason]
		,[CreateDT]
	)
values
	(
		@parRID	
		,@parKey
		,@parVal
		,@parReason
		,getdate()
	)

go


GRANT EXECUTE ON [SvcSetValEnqueue] TO ExecuteOnlyRole
go


