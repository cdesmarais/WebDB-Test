if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_CallerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_CallerUpdate]
GO

CREATE PROCEDURE dbo.AA_CallerUpdate

@CallerID int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@Email nvarchar(255),
@Login nvarchar(255),
@MetroAreaID int,
@Password  nvarchar(255),
@Phone nvarchar(24),
@SendAnnouncements bit,
@BirthMonth int=null,
@BirthYear int=null,
@Salutation int,
@Notes nvarchar(255)=null,
@retval int  = 0 OUTPUT 

As

SET NOCOUNT ON

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

BEGIN TRANSACTION

  --check for dup email
  declare @n int
  Select @n = Count(CustID) from Customer where email = @email 
  if @n > 0 Goto email_error

  Select @n = Count(CallerID) from Caller where email = @email and CallerID <> @CallerID and PositionID = 3
  if @n > 0 Goto email_error

--get the original email and PositionIDfrom Caller.  we will use this to update CallerCustomer
  Declare @OrigEmail nvarchar(255),@PositionID int,@OrigFName nvarchar(255),@OrigLName nvarchar(255)
  Select @OrigEmail = Email,@OrigFName = FName,@OrigLName = LName,@PositionID = PositionID from Caller where CallerID = @CallerID


 -- per TT 46378 we want to track whenever we try to insert logins and emails that don't match
	Declare @Enable int
	select @Enable = ValueInt from ValueLookup where LKey = 'Caller_Instrumentation' and LType = 'WEBSERVER'
	IF (@PositionID = 3 and @Enable = 1)
	BEGIN
		IF (@Login != @Email or @Email is null or @Login is null)
		BEGIN
		declare @ErrorMsg as nvarchar(4000)	
		set @ErrorMsg = N'Caller update login/email mismatch (callerid ' + cast(@CallerID as nvarchar(255)) + ') - login: ''' 
			+ cast(ISNULL(@Login,'NULL') as nvarchar(255)) 
			+ ''', email: ''' + cast(ISNULL(@Email,'NULL') as nvarchar(255)) + ''''
		exec DNErrorAdd 423, 'AA_CallerUpdate', @ErrorMsg, 2
		END
	end


--Do Caller and CallerPhone Updates
  UPDATE Caller set FName = @FirstName,LName = @LastName,Email = @Email,metroareaid = @MetroAreaID,LoginName = @Login,
	SendAnnouncements = @SendAnnouncements,Salutation = @Salutation,BirthMonth = @BirthMonth,BirthYear = @BirthYear,Notes = @Notes
	WHERE CallerID = @CallerID
  IF @@Error <> 0  
     goto error
  UPDATE CallerPhone set Phone = @Phone where CallerID = @CallerID
  IF @@Error <> 0  
     goto error
	 
   UPDATE UserOptin
	SET Insider = @SendAnnouncements, DinersChoice= @SendAnnouncements, NewHot= @SendAnnouncements, RestaurantWeek= @SendAnnouncements, Promotional= @SendAnnouncements
		,SpotLight=@SendAnnouncements, Product=@SendAnnouncements, UpdatedDtUTC= getutcdate()
	WHERE CallerID = @CallerID

--if the Caller is an admin,do CallerCustomer and CustomerPhone Updates
  IF @PositionID = 3
  Begin
     UPDATE CallerCustomer set FName = @FirstName,LName = @LastName,Email = @Email where Email = @OrigEmail and FName = @OrigFName and LName = @OrigLName
     Declare @CustID int
     Select @CustID = CustID from CallerCustomer where Email = @Email
     IF @@Error <> 0  
     goto error
  
     UPDATE CustomerPhone set Phone = @Phone where CustID = @CustID
     IF @@Error <> 0  
     goto error
  End

COMMIT TRANSACTION

Return(0)

error:
BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('7',17,1)
         Select @retval = 0
         RETURN(2)
END

email_error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('4',17,1)
         Set @retval = 0
         RETURN(1)
      END
GO

GRANT EXECUTE ON [AA_CallerUpdate] TO ExecuteOnlyRole

GO
