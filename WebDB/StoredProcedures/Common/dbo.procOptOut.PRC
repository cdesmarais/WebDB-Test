GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procOptOut]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procOptOut]
GO


CREATE procedure dbo.procOptOut

as
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

update Caller 
set    SendAnnouncements = 0
where  email in (select email from Unsubs)

update UserOptIn 
	set Insider=0,DinersChoice=0,NewHot=0,RestaurantWeek=0,Promotional=0,SpotLight=0,Product=0,UpdatedDtUTC=getutcdate()
where	CallerID  in (select CallerID from caller with (nolock) where email in (select email from Unsubs))

update Customer 
set    SendAnnouncements = 0
where  email in (select email from Unsubs)

update UserOptIn 
	set Insider=0,DinersChoice=0,NewHot=0,RestaurantWeek=0,Promotional=0,SpotLight=0,Product=0,UpdatedDtUTC=getutcdate()
where  CustID  in (select CustID from Customer with (nolock) where email in (select email from Unsubs))

delete from Unsubs

return


GO


GRANT EXECUTE ON [procOptOut] TO ExecuteOnlyRole
GO
