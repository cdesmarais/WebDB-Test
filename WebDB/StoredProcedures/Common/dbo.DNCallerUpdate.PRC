/* Note that this procedure is being replaced by DNCallerUpdate2 for the 2008 WR12 release. It can be removed sometime after the WR12 release */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCallerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCallerUpdate]
GO


CREATE PROCEDURE dbo.DNCallerUpdate

@CallerID int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@SortableFName nvarchar(255),
@SortableLName nvarchar(255),
@Email nvarchar(255),
@Login nvarchar(255),
@Address1 nvarchar(128),
@Address2 nvarchar(128),
@City nvarchar(40),
@State nvarchar(40),
@ZipCode nvarchar(20),
@Country char(2),
@MetroAreaID int,
@Password  nvarchar(255),
@PhoneCountryID char(2),
@Phone nvarchar(24),
@MobilePhoneCountryID char(2) = NULL,
@MobilePhone nvarchar(24) = NULL,
@SendAnnouncements bit,
@BirthMonth int=null,
@BirthYear int=null,
@Salutation int,
@Notes nvarchar(255)=null,
@PwdQuestionID int,
@PwdAnswer nvarchar(255),
@retval int  = 0 OUTPUT 

As
SET NOCOUNT ON

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

Exec DNCallerUpdate2		 	@CallerID,
								@FirstName,
								@LastName,
								@SortableFName,
								@SortableLName,
								@Email,
								@Login,
								@Address1,
								@Address2,
								@City,
								@State,
								@ZipCode,
								@Country,
								@MetroAreaID,
								@Password,
								@PhoneCountryID,
								@Phone,
								@MobilePhoneCountryID,
								@MobilePhone,
								null, --Don't change the email preferences becuase they now live on a UserOptIn table
								@BirthMonth,
								@BirthYear,
								@Salutation,
								@Notes,
								@PwdQuestionID,
								@PwdAnswer,
								1, -- DiningFormEmailOptIn default value of 1
								@retval output

Return(0)
GO


GRANT EXECUTE ON [DNCallerUpdate] TO ExecuteOnlyRole

GO



