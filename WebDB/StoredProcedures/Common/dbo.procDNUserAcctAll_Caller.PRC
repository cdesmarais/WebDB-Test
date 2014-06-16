if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserAcctAll_Caller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserAcctAll_Caller]
GO

CREATE PROCEDURE dbo.procDNUserAcctAll_Caller
(
    @UserID int,
    @TodayDate datetime,
    @when int = 0
)
AS
--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	procDNUserAcctAll_Caller
--**	procDNUserAcctAll_Cust
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


-- Set the AdminCustId and Original CustID
-- For Customers these values are always null; 
-- for Callers this represents the CallerCustID (AdminCustID) 
--     and the original customer id (id before user converted to a caller)
Declare @AdminCustID int
Declare @OriginalCustID int
select 		@AdminCustID = null,
       		@OriginalCustID = null

Select 			@AdminCustID = cc.CustID,
				@OriginalCustID = c.CustID
From			CallerCustomer cc
Left Join		Customer c 
On 				cc.CallerID = c.CallerID
Where			cc.CallerID = @UserID
And				cc.IsAdmin = 1


if @when = 0
BEGIN
	exec dbo.procDNUserAcctAll__Caller_whenZero @UserID, @TodayDate, @AdminCustID, @OriginalCustID
END
else
BEGIN
	exec dbo.procDNUserAcctAll__Caller_whenOne @UserID, @TodayDate, @AdminCustID, @OriginalCustID 
END

GO


GRANT EXECUTE ON [procDNUserAcctAll_Caller] TO ExecuteOnlyRole

go
