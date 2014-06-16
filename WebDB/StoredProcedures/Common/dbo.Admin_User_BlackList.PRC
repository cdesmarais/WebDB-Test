if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_BlackList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_BlackList]
GO

--
-- Proc for Blacklisting a user account
-- (calls dbo.Admin_User_ChangeStatus)
-- TT 26788 mmc WR2008_11
create procedure dbo.Admin_User_BlackList
(
  @customerID int=0,
  @CallerID int=0,
  @CHARMUserID int,
	@CHARMUserEmail varchar(50),
	@SourceIPAddress varchar(25)
)
as

	declare @AllPoints int
	declare @AdjustmentReasonID int
	declare @DeactivationReasonID int
	declare @BlacklistMsg nvarchar(100)

	set @BlacklistMsg = 'Blacklisted in CHARM by ' + @CHARMUserEmail

	begin transaction

-- first, get the points adjustment reason and the Deactivation reason
	select @AdjustmentReasonID = AdjReasonID
	from   PointsAdjustmentReason
	where  CHARMExplanation = 'Blacklist User Account'

	select @DeactivationReasonID = ReasonID
	from   ReasonForDeactivation
	where  ReasonDesc = 'Blacklisted'


-- BLACKLIST A CALLER
	if @CallerID <> 0 
	begin
		-- deactivate the caller, use Blacklist status code
		exec dbo.Admin_User_ChangeStatus @CustomerID = @CustomerID, @CallerID = @CallerID, @status = 4

		-- add a record to the DeactivatedCustomer table (not strictly necessary for callers, but 
		-- included for consistency)
		insert into CustomersDeactivated (CustID, ReasonID, DateDeactivated, CallerID)
			values (NULL,  @DeactivationReasonID, getdate(), @CallerID)

		insert into FraudChangeLog(Custid,CallerID,FraudStatusID,CreateDT,ChangedBy)
			values( @CustomerID, @callerID, 5, getdate(), @CHARMUserEmail)				-- 5 = Blacklisted
			
			
		-- deducting all points, so get 'em
		select @AllPoints = Points from Caller where CallerID = @CallerID

		-- clear the points
		exec Admin_DeductPointsToCustomer @CustomerID = @CallerID, @IsCaller = 1,
				@Points = @AllPoints, @Reason = @AdjustmentReasonID, @CHARMUserID = @CHARMUserID,
				@CHARMUserEmail = @CHARMUserEmail, @SourceIPAddress = @SourceIPAddress,
				@AdjusterOtherReason = NULL

		if (@@error <> 0)
			goto general_error

		-- Update the dining check blacklist
		insert into DCHK_BlackList(CustID,CallerID,Email,Address1,Address2,City,State,DT,Active,Note)
		select	 null
				,c.CallerID
				,c.Email
				,c.Address1
				,c.Address2
				,c.City
				,c.State
				,getdate()
				,1
				,@BlacklistMsg
		from	Caller c
		left join	DCHK_BlackList bl
		on			bl.CallerID = c.CallerID
		where		c.callerid = @callerid
		and			bl.callerid is null		-- not already in blacklist
		
		if (@@error <> 0)
			goto general_error

	end
	else if @CustomerID <> 0
	begin
		-- deactivate the caller, but use the normal "inactive" status code
		exec dbo.Admin_User_ChangeStatus @CustomerID = @CustomerID, @CallerID = @CallerID, @status = 0

		-- add a record to the DeactivatedCustomer table 
		insert into CustomersDeactivated (CustID, ReasonID, DateDeactivated, CallerID)
			values (@CustomerID,  @DeactivationReasonID, GETDATE(), NULL)

		insert into FraudChangeLog(Custid,CallerID,FraudStatusID,CreateDT,ChangedBy)
			values( @CustomerID, @callerID, 5, getdate(), @CHARMUserEmail)				-- 5 = Blacklisted

		-- deducting all points, so get 'em
		select @AllPoints = Points from Customer where CustID = @CustomerID
		-- clear the points

		exec Admin_DeductPointsToCustomer @CustomerID = @CustomerID, @IsCaller = 0,
				@Points = @AllPoints, @Reason = @AdjustmentReasonID, @CHARMUserID = @CHARMUserID,
				@CHARMUserEmail = @CHARMUserEmail, @SourceIPAddress = @SourceIPAddress,
				@AdjusterOtherReason = NULL

		if (@@error <> 0)
			goto general_error

		-- Update the dining check blacklist
		insert into DCHK_BlackList(CustID,CallerID,Email,Address1,Address2,City,State,DT,Active,Note)
		select	 c.custid
				,null
				,c.Email
				,c.Address1
				,c.Address2
				,c.City
				,c.State
				,getdate()
				,1
				,@BlacklistMsg
		from		Customer c
		left join	DCHK_BlackList bl
		on			bl.CustID = c.custid
		where		c.custid = @customerID
		and			bl.custid is null		-- not already in blacklist

		if (@@error <> 0)
			goto general_error

	end

	commit transaction
	return(0)

general_error:
	
	rollback transaction
	return(0)

go

grant execute on [Admin_User_BlackList] to ExecuteOnlyRole
go
