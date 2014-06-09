if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_Caller_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_Caller_GetByID]
GO

CREATE PROCEDURE dbo.AA_Caller_GetByID

@CallerID int

 AS
Set nocount on
Set transaction isolation level read uncommitted

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

Select 
	c.FName as First_Name
	,c.LName as Last_Name
	,c.Email
	,'' as Password
	,c.PwdQuestionID as Password_Question_ID
	,c.PwdAnswer as Password_Answer
	,cp.Phone
	,c.MetroAreaID as Metro_Area_ID
	,c.SendAnnouncements
	,c.LoginName as Login_Name
	,ma.MetroAreaName as MetroName
	,BirthMonth as Birth_month
	,BirthYear as Birth_Year
	,Salutation
	,Exported
	,Notes

from		Caller c
inner join	CallerPhone cp
on			c.CallerID = cp.CallerID AND cp.IsPrimary = 1 
inner join	MetroAreaVW ma
on			c.metroareaid = ma.metroareaid
LEFT OUTER JOIN EmailUpdates eu
On			c.CallerID = eu.userid 
and			eu.isCaller = 1 
and			eu.PartnerID = c.PartnerID
where c.CallerID = @CallerID

GO

GRANT EXECUTE ON [AA_Caller_GetByID] TO ExecuteOnlyRole

GO
