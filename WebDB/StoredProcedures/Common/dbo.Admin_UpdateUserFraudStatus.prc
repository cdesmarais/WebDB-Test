if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateUserFraudStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateUserFraudStatus]
go

create procedure dbo.Admin_UpdateUserFraudStatus 
	 @CustID		int
	,@IsCaller		bit
	,@LastChangedBy	nvarchar(50)
	,@FraudStatusID	int
as 
begin

	set transaction isolation level read uncommitted
	
	begin tran	-- transaction only so we can rollback on wrong rowcount
	
	declare  @CallerID				int
			,@rc					int
			,@msg					varchar(256)
			,@ProbationStartDate	datetime
			
	set @CallerID = null
	set @ProbationStartDate = null
	
	if @IsCaller = 1
	begin
		set @CallerID = @custid
		set @custid = null
	end
	
	-- Special case: set the probation start date if we're putting user on probation
	if @FraudStatusID = 3
	begin
		set @ProbationStartDate = getdate()
	end
			
	update	SuspectedFraudulentAccounts
	set		 FraudStatusID		= @FraudStatusID
			,ProbationStartDate = @ProbationStartDate
			,LastChangedBy		= @LastChangedBy
	where	isnull(-1*callerid,custid) = isnull(-1*@callerid, @custid)
	
	set @rc = @@rowcount
	if @rc != 1
		goto error_proc

	commit tran
	goto exit_proc	
	
error_proc:
	rollback tran
	set @msg = 'Expected one record updated but got ' + cast( @rc as varchar) + ' - rolled back update.'
	raiserror(@msg, 16, 1)
	return 1
		
exit_proc:
	return 0
	
end 	
go

GRANT EXECUTE ON [Admin_UpdateUserFraudStatus] TO ExecuteOnlyRole
GO
