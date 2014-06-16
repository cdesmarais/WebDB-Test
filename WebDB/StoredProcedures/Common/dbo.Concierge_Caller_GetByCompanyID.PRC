if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_GetByCompanyID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_GetByCompanyID]
GO



CREATE PROCEDURE dbo.Concierge_Caller_GetByCompanyID

@CompanyID int,
@isactive int = 0

AS

BEGIN TRANSACTION
if @isactive = 0
BEGIN
	select Caller.CallerID as Caller_ID
		,Caller.FName as First_Name
		,Caller.LName as Last_Name
		,'' as Password
		,Caller.LoginName as Login_Name
		,Caller.callerstatusid as Caller_Status_ID
		,Caller.SFName as Sortable_First_Name
		,Caller.SLName as Sortable_Last_Name
	from Company 
	inner join Caller on Company.CompanyID = Caller.CompanyID 
	where Caller.CompanyID = @CompanyID
	order by Caller.callerstatusid,Caller.SLName,Caller.FName,Caller.LName
END
if @isactive = 1
BEGIN
	select Caller.CallerID as Caller_ID
		,Caller.FName as First_Name
		,Caller.LName as Last_Name
		,'' as Password
		,Caller.LoginName as Login_Name
		,Caller.callerstatusid as Caller_Status_ID
		,Caller.SFName as Sortable_First_Name
		,Caller.SLName as Sortable_Last_Name
	from Company 
	inner join Caller on Company.CompanyID = Caller.CompanyID 
	where Caller.CompanyID = @CompanyID and Caller.callerstatusid = 1
	order by Caller.callerstatusid,Caller.SLName,Caller.FName,Caller.LName
END

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Caller_GetByCompanyID] TO ExecuteOnlyRole

GO
