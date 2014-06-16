if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_ChangeStatusAndLogHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_ChangeStatusAndLogHistory]
go

create procedure dbo.Admin_User_ChangeStatusAndLogHistory
(
	 @CustomerID		int=0
	,@CallerID			int=0
	,@Status			int
	,@CHARMUserEmail	varchar(50)
)
as
begin 

	set transaction isolation level read uncommitted
	set nocount on
	
	begin transaction
	
	declare @FraudStatusID int

	exec Admin_User_ChangeStatus @CustomerID, @CallerID, @Status
	if (@@error <> 0)
		goto general_error

	-- For regular customers
	if @Status = 0 and @CustomerID > 1
		-- Deactivated
		set @FraudStatusID = 6
	-- For callers		
	else if	@Status > 1 and @CallerID > 1
		-- Deactivated
		set @FraudStatusID = 6
	else
	begin
		-- reset to status in fraud table f it's there, otherwise set to active via isnull below
		select @FraudStatusID = FraudStatusID from SuspectedFraudulentAccounts sfa where CallerID = @CallerID
	end
		
	insert into FraudChangeLog(Custid,CallerID,FraudStatusID,CreateDT,ChangedBy)
		values( @CustomerID, @callerID, isnull(@FraudStatusID,1), getdate(), @CHARMUserEmail)				

	if (@@error <> 0)
		goto general_error

	commit transaction
	return 0

general_error:
	rollback transaction
	raiserror('Error changing status of user.', 16,1)
	return -1

end	
go

grant execute on [Admin_User_ChangeStatusAndLogHistory] TO ExecuteOnlyRole

go
