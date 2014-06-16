if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_GetByID]
GO

CREATE Procedure dbo.Concierge_Caller_GetByID
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR9 2010
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************

SELECT 
Caller.FName AS FirstName,
    Caller.LName AS LastName,
    Caller.LoginName AS LoginName,
    Caller.EMail,
	'' as Password,
    Caller.PwdQuestionID AS PasswordQuestionID,
    Caller.PwdAnswer AS PasswordAnswer,
    Caller.CompanyID AS CompanyID,
	Caller.PartnerID as PartnerID,
    Caller.Notes AS Notes,
    Company.CompanyName as CompanyName,
    Company.Logo as CompanyLogo,
    Company.FaxPhone AS FaxPhone,
    PasswordQuestion.Question AS PasswordQuestion,
    Caller.metroareaid AS DefaultGeoID,
    CallerPhone.Phone AS DayPhone,
    Caller.Points,
    Company.Address1 as Address,
    Company.Address2,
    Company.City,
    Company.State,
    Company.Zip as Postal_code
,SendAnnouncements
,Company.acceptspoints as accepts_points
,ma.MetroAreaName as MetroName
,coalesce(SearchTypeID,1) as SearchType_ID
,donatepoints as donate_points
,isCharity as is_Charity
FROM Caller 
INNER JOIN Company 
ON Caller.CompanyID = Company.CompanyID
INNER JOIN MetroAreaVW ma
on Caller.metroareaid = ma.metroareaid
INNER JOIN PasswordQuestion
 on PasswordQuestion.PwdQuestionID = Caller.PwdQuestionID
LEFT OUTER JOIN CallerPhone 
ON  Caller.CallerID = CallerPhone.CallerID
WHERE (Caller.CallerID = @UserID)

GO

GRANT EXECUTE ON [Concierge_Caller_GetByID] TO ExecuteOnlyRole

GO
