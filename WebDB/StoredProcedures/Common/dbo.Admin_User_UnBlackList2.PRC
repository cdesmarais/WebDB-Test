if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_UnBlackList2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_UnBlackList2]
GO

--
-- Proc for UnBlacklisting a user account
-- TT 26788 mmc WR2008_11
create procedure dbo.Admin_User_UnBlackList2
(
	  @CustomerID int=0
	 ,@CallerID int=0
	 ,@CHARMUserEmail varchar(50)=null
)
as
begin

	begin transaction

	declare @FraudStatusID int

	-- set the caller/customer number and flag
	if @CallerID <> 0 
	begin
		-- get rid of the CustomersDeactivated record
		delete from CustomersDeactivated where CallerID = @CallerID

		if (@@error <> 0)
			goto general_error

		delete from DCHK_Blacklist where CallerID = @CallerID

		if (@@error <> 0)
			goto general_error

		--  set the status to active
		update	Caller
		set		CallerStatusID = 1
		where	CallerID = @CallerID

		if (@@error <> 0)
			goto general_error

		select @FraudStatusID = FraudStatusID from SuspectedFraudulentAccounts sfa where CallerID = @CallerID
		insert into FraudChangeLog(Custid,CallerID,FraudStatusID,CreateDT,ChangedBy)
			values( @CustomerID, @callerID, isnull(@FraudStatusID,1), getdate(), @CHARMUserEmail)				
		
		if (@@error <> 0)
			goto general_error

	end
	else if @CustomerID <> 0
	begin
		-- regular customer
		-- get rid of the CustomersDeactivated record
		delete from CustomersDeactivated where CustID = @CustomerID

		if (@@error <> 0)
			goto general_error

		delete from DCHK_Blacklist where CustID = @CustomerID

		if (@@error <> 0)
			goto general_error

		--  Set the status to active
		update	Customer
		set		Active = 1
		where	CustID = @CustomerID

		if (@@error <> 0)
			goto general_error

		select @FraudStatusID = FraudStatusID from SuspectedFraudulentAccounts sfa where CustID = @CustomerID
		insert into FraudChangeLog(Custid,CallerID,FraudStatusID,CreateDT,ChangedBy)
			values( @CustomerID, @callerID, isnull(@FraudStatusID,1), getdate(), @CHARMUserEmail)				
		
		if (@@error <> 0)
			goto general_error

	end

	commit transaction
	return(0)

general_error:
	rollback transaction
	return(0)

end	
go

grant execute on [Admin_User_UnBlackList2] to ExecuteOnlyRole

go
