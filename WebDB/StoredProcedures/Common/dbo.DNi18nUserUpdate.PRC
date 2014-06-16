if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNi18nUserUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNi18nUserUpdate]
GO

CREATE Procedure dbo.DNi18nUserUpdate
 (
  @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @SortableFName nvarchar(255),
  @SortableLName nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @SendAnnouncements int,
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @State nvarchar(255),
  @ZipCode nvarchar(255),
  @Country char(2),
  @PhoneCountryID char(2),
  @DayPhone nvarchar(24),
  @DefaultGeoID int,
  @DefaultRequests nvarchar(999),
  @BirthMonth int=null,
  @BirthYear int=null,
  @Salutation int,
  @TheDiningFormOptIn bit
 )
As

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

Exec DNUserUpdate  @UserID, @FirstName, @LastName, @SortableFName, @SortableLName, @Email, @Password,
  @SendAnnouncements, @Address1,@Address2,@City, @State, @ZipCode, @Country, @PhoneCountryID,
  @DayPhone,  NULL, NULL, @DefaultGeoID, @DefaultRequests, @BirthMonth, @BirthYear,
  @Salutation, @TheDiningFormOptIn


GO

GRANT EXECUTE ON [DNi18nUserUpdate] TO ExecuteOnlyRole

GO
