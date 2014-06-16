if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserAcctAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserAcctAll]
GO

CREATE PROCEDURE dbo.DNUserAcctAll
(
    @UserID int,
    @IsCaller bit,
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

if @IsCaller = 1
BEGIN
	exec procDNUserAcctAll_Caller @UserID, @TodayDate, @when
END
else
BEGIN
	exec procDNUserAcctAll_Cust @UserID, @TodayDate, @when
END

GO


GRANT EXECUTE ON [DNUserAcctAll] TO ExecuteOnlyRole

go
