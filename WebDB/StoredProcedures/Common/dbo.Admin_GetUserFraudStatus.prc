if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetUserFraudStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetUserFraudStatus]
GO

CREATE PROCEDURE dbo.Admin_GetUserFraudStatus(
@UserID int,
@IsCaller bit
)

AS

set nocount on
set transaction isolation level read uncommitted

--Fetch the user's fraud status

if @IsCaller = 0
	select			c.FName + ' ' + c.LName Name,
					(case when c.Active = 0 then 'De-activated' else 'Active' end) AccountStatus,
					fs.FraudStatusDescription FraudStatus,
					(case when fs.FraudStatusID in (2,3,4,7) then 1 else 0 end) ResetOk,
					c.CustID CustomerID
	from			Customer c
	left join		SuspectedFraudulentAccounts sfa
	on				c.CustID = sfa.CustID
	left join		FraudStatus fs
	on				sfa.FraudStatusID = fs.FraudStatusID
	where			c.CustID = @UserID
else
	select			c.FName + ' ' + c.LName Name,
					(case when c.CallerStatusID = 1 then 'Active' else 'De-activated' end) AccountStatus,
					fs.FraudStatusDescription FraudStatus,
					(case when fs.FraudStatusID in (2,3,4,7) then 1 else 0 end) ResetOk,
					c.CallerID CustomerID
	from			Caller c
	left join		SuspectedFraudulentAccounts sfa
	on				c.CallerID = sfa.CallerID
	left join		FraudStatus fs
	on				sfa.FraudStatusID = fs.FraudStatusID
	where			c.CallerID = @UserID

return 0
GO


GRANT EXECUTE ON [Admin_GetUserFraudStatus] TO ExecuteOnlyRole

GO

