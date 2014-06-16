if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Travel_User_GetProfileByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Travel_User_GetProfileByID]
GO

CREATE PROCEDURE dbo.Travel_User_GetProfileByID
 (
  @UserID int
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
-- ** Embedded for WR9 2010
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

SELECT Caller.FName AS FirstName, 
    Caller.LName AS LastName, 
    coalesce(Caller.EMail,'') As email,
    Caller.LoginName, 
	'' As SID,
    Caller.SendAnnouncements,
    CallerPhone.PhoneTypeID AS PhoneType, 
    CallerPhone.Phone
FROM Caller 
INNER JOIN
    PasswordQuestion 
    ON  Caller.PwdQuestionID = PasswordQuestion.PwdQuestionID 
LEFT OUTER JOIN  CallerPhone 
    ON  Caller.CallerID = CallerPhone.CallerID AND CallerPhone.IsPrimary = 1
WHERE (Caller.CallerID = @UserID)

GO

GRANT EXECUTE ON [Travel_User_GetProfileByID] TO ExecuteOnlyRole

GO
