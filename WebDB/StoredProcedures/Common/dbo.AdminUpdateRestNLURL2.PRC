if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminUpdateRestNLURL2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminUpdateRestNLURL2]
go

create procedure dbo.AdminUpdateRestNLURL2
(
	 @RID			int
	,@SingleName	nvarchar(255)
	,@City			nvarchar(40)
	,@ProfileName	nvarchar(255)
	,@UpdatedBy		nvarchar(100)
	,@ErrorType 	int output
)
as

set nocount on
set transaction isolation level read uncommitted
set ansi_warnings on
set arithabort on 
set quoted_identifier on

set @ErrorType = 0
declare @SingleNLData1 nvarchar(200), @SingleNLData2 nvarchar(200), @ProfileNLData1  nvarchar(200)

set @SingleNLData1 =  dbo.Rstrip(dbo.Lstrip(dbo.fNLURLEncode(@SingleName), '-'), '-');
set @SingleNLData2 =  dbo.Rstrip(dbo.Lstrip(dbo.fNLURLEncode(@City), '-'), '-');
set @ProfileNLData1 =  dbo.Rstrip(dbo.Lstrip(dbo.fNLURLEncode(@ProfileName), '-'), '-');

declare @modDate datetime, @myerror int
set @modDate = getdate()
set @myerror  = 0

declare @bModifySingle bit, @bModifyProfile bit
set @bModifySingle = 0
set @bModifyProfile = 0

declare @count int
set @count = 0

declare @oldNLData1 nvarchar(200), @oldNLData2 nvarchar(200)

select @count = count(*), @oldNLData1= NLData1, @oldNLData2 = NLData2
from NLData
where 	NLRuleID=1    -- NL Rule for single.aspx
		and RID=@RID
		and MapFilePublishedDt is null
group by NLData1, NLData2

begin transaction UpdateRestNLURL
		
if (@count > 0)
begin
	if (@oldNLData1 != @SingleNLData1 OR @oldNLData2 != @SingleNLData2) 
	begin
		update NLData 
			set NLData1 = @SingleNLData1,
				NLData2 = @SingleNLData2,
				LastModifiedDT = @modDate
		where
				NLRuleID=1      -- NL Rule for single.aspx
				and RID=@RID
				and MapFilePublishedDt is null
		
		set @myerror = @@error
		if (@myerror != 0) 
		begin
			set @ErrorType = 1
			goto handle_error
		end	
		
		set @bModifySingle = 1
	end 
end else
begin
	select @count = count(*), @oldNLData1= NLData1, @oldNLData2 = NLData2
	from NLURLVw
	where 	NLRuleID=1    -- NL Rule for single.aspx
		and RID=@RID
		and Active=1 
	group by NLData1, NLData2
	
	if (@count > 0)
	begin
		if (@oldNLData1 != @SingleNLData1 OR @oldNLData2 != @SingleNLData2)
			set @bModifySingle = 1
	end else
	begin
		set @bModifySingle = 1
	end

	
	if (@bModifySingle = 1) 
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
			,@SingleNLData1
			,@SingleNLData2
			,@modDate
		)
		set @myerror = @@error
		if (@myerror != 0) 
		begin
			set @ErrorType = 1
			goto handle_error
		end
	end
end

set @count = 0
	
select @count = count(*), @oldNLData1= NLData1
from NLData
where 	NLRuleID=8    -- NL Rule for rest_profile.aspx
		and RID=@RID
		and MapFilePublishedDt is null
group by NLData1

if (@count > 0)
begin
	if (@oldNLData1 != @ProfileNLData1) 
	begin
		update NLData 
			set NLData1 = @ProfileNLData1,
				LastModifiedDT = @modDate
		where
				NLRuleID=8      -- NL Rule for rest_profile.aspx
				and RID=@RID
				and MapFilePublishedDt is null
		set @myerror = @@error
		if (@myerror != 0) 
		begin
			set @ErrorType = 2
			goto handle_error
		end		
		set @bModifyProfile = 1
	end 
end else
begin
	select @count = count(*), @oldNLData1= NLData1
	from NLURLVw
	where 	NLRuleID=8   -- NL Rule for rest_profile.aspx
		and RID=@RID
		and Active=1 
	group by NLData1
	
	if (@count > 0)
	begin
		if (@oldNLData1 != @ProfileNLData1)
			set @bModifyProfile = 1
	end else
	begin
		set @bModifyProfile = 1
	end 
	
	if (@bModifyProfile = 1)
	begin
		insert into NLData (
			NLRuleID
			,RID
			,NLData1
			,LastModifiedDT
			)
		values
		(
			8				--NLRuleID for rest_profile.aspx
			,@RID
			,@ProfileNLData1
			,@modDate
		)
		set @myerror = @@error
		if (@myerror != 0) 
		begin
			set @ErrorType = 2
			goto handle_error
		end
	end
end
	
if (@bModifySingle = 1 OR @bModifyProfile = 1)
begin	
	-- update the audit log table
	insert into RestNLChangeLog (
		 RID
		,NLData1
		,NLData2
		,NLData1Profile
		,UpdatedBy
		,UpdatedDT
		)
	values
	(
		 @RID
		,@SingleNLData1
		,@SingleNLData2
		,@ProfileNLData1
		,@UpdatedBy
		,@modDate
	)
		
	set @myerror = @@error	
	if (@myerror != 0) 
		goto handle_error

	commit transaction UpdateRestNLURL
	return (0)
end

handle_error:
	rollback transaction UpdateRestNLURL
	return (@myerror)
go

grant execute on [dbo].[AdminUpdateRestNLURL2] to ExecuteOnlyRole
go