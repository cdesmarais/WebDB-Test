if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_ReportSelectUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_ReportSelectUser]
GO




CREATE PROCEDURE dbo.Concierge_Reservation_ReportSelectUser
(
  @CompanyID int
)
AS

BEGIN TRANSACTION

select 
	Caller.CallerID as Caller_ID,
	Caller.FName as First_Name,
	Caller.LName as Last_Name,
	'' as Password,
	Caller.LoginName as Login_Name,
	Caller.callerstatusid as Caller_Status_ID
from dbo.Company 
inner join dbo.Caller 
	on Company.CompanyID = Caller.CompanyID 
where 
	Caller.CompanyID = @CompanyID and Caller.callerstatusid = 1
Order By FName

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Reservation_ReportSelectUser] TO ExecuteOnlyRole

GO
