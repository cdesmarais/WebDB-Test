if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminUpdateRestNLURL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminUpdateRestNLURL]
go

create procedure dbo.AdminUpdateRestNLURL
(
	 @RID			int
	,@RName			nvarchar(255)
	,@City			nvarchar(40)
	,@UpdatedBy		nvarchar(100)
)
as

set nocount on
set transaction isolation level read uncommitted
set ansi_warnings on
set arithabort on 
set quoted_identifier on

declare @NLData1 nvarchar(200), @NLData2 nvarchar(200)

set @NLData1 =  dbo.Rstrip(dbo.Lstrip(dbo.fNLURLEncode(@RName), '-'), '-');
set @NLData2 =  dbo.Rstrip(dbo.Lstrip(dbo.fNLURLEncode(@City), '-'), '-');

declare @modDate datetime, @myerror int
set @modDate = getdate()

declare @count int

select @count = count(*)
from NLData
where 	NLRuleID=1    -- NL Rule for single.aspx
		and RID=@RID
		and MapFilePublishedDt is null

begin transaction UpdateRestNLURL
		
if (@count > 0)
begin
	update NLData 
		set NLData1 = @NLData1,
			NLData2 = @NLData2,
			LastModifiedDT = @modDate
	where
			NLRuleID=1      -- NL Rule for single.aspx
			and RID=@RID
			and MapFilePublishedDt is null
end else
begin
	insert into NLData (
		NLRuleID
		,RID
		,NLData1
		,NLData2
		,LastModifiedDT
		)
	values
	(
		1				--NLRuleID for single.aspx
		,@RID
		,@NLData1
		,@NLData2
		,@modDate
	)
end

select @myerror = @@error
if (@myerror != 0) 
	goto handle_error
	
-- update the audit log table
insert into RestNLChangeLog (
	 RID
	,NLData1
	,NLData2
	,UpdatedBy
	,UpdatedDT
	)
values
(
	 @RID
	,@NLData1
	,@NLData2
	,@UpdatedBy
	,@modDate
	)
	
select @myerror = @@error	

if (@myerror != 0) 
	goto handle_error

commit transaction UpdateRestNLURL
return (0)

handle_error:
	rollback transaction UpdateRestNLURL
	return (@myerror)
go

grant execute on [dbo].[AdminUpdateRestNLURL] to ExecuteOnlyRole
go