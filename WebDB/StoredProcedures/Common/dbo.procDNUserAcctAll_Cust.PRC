if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserAcctAll_Cust]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserAcctAll_Cust]
GO

CREATE PROCEDURE dbo.procDNUserAcctAll_Cust
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

if @when = 0
BEGIN
	exec dbo.procDNUserAcctAll__Cust_whenZero @UserID,  @TodayDate, @AdminCustID, @OriginalCustID 
END
else
BEGIN
	exec dbo.procDNUserAcctAll__Cust_whenOne @UserID,  @TodayDate, @AdminCustID, @OriginalCustID 
END
GO


GRANT EXECUTE ON [procDNUserAcctAll_Cust] TO ExecuteOnlyRole

go
