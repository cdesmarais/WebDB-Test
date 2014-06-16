--*********************************
--** This proc appears to never be used; EV 6-8-2005
--*********************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserConvertAnon]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserConvertAnon]
GO


CREATE Procedure dbo.DNUserConvertAnon
 (
  @Customer_ID int,
  @newpassword nvarchar(50),
  @isAdmin int
  )
As

SET NOCOUNT ON

--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR2 2011
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


BEGIN TRAN

Declare @UserEmail nvarchar(50),@ConsumerType int,@HasBeenConverted int,@Caller_ID int
  
  Declare @RegPoints int
Set @RegPoints = 0
  
Set @HasBeenConverted = 0

Select @UserEmail = email,@ConsumerType = ConsumerType from Customer where CustID = @Customer_ID
if right(@UserEmail,8) = 'isAAUser'
BEGIN
	Set @HasBeenConverted = 1
END	

--See if account has been converted to regular user,if not convert
if exists(Select CustID from Customer where CustID = @Customer_ID and ConsumerType = 8) and @HasBeenConverted = 0
BEGIN

	-- Converting an annon user to standard user should award current / standard reg points
	-- This means old points should be deleted if they exist
	Update Customer set ConsumerType = 1,points = @RegPoints,SendAnnouncements = 1 where CustID = @Customer_ID
	
	--********************************
	--** 0 Points for all Resos not pending
	--** NOTE: Promos associated with these resos will still be active
	--*******************************
	Update Reservation set ResPoints = 0 where CustID = @Customer_ID and RStateID <> 1

	if (@@error <> 0)
		GOTO general_error

	if @isAdmin = 1
	BEGIN

		--********************************
		--** DeActivate Current Customer Record
		--** And Create a new Active Caller based on the Customer Record
		--** Update all Caller Related Data
		--********************************
		Exec DNChangeRealCustomerToAAUser @CustomerEmail = @UserEmail
		if (@@error <> 0)
			GOTO general_error
		Select @Caller_ID = CallerID from Caller where email = @UserEmail

		--********************************
		--** Log the Conversion
		--********************************
		Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @Caller_ID,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

		if (@@error <> 0)
			GOTO general_error
			

		Select CallerID as UserID,email,FName as First_Name,1 as Updated from Caller where email = @UserEmail

	
	END
	else
	BEGIN
		--********************************
		--** Log the Conversion
		--********************************
		Exec User_Convert_Consumer_Type @Customer_ID = @Customer_ID,@Caller_ID = null,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

		if (@@error <> 0)
			GOTO general_error
			
				-- Set Email Opt-In preferences
        declare @MetroAreaID int
	    select @MetroAreaID = MetroAreaID from Customer with (nolock) where CustID= @Customer_ID
		IF NOT EXISTS(SELECT CustID from UserOptIn with (nolock) where CustID= @Customer_ID AND MetroAreaID = @MetroAreaID)				
			insert UserOptIn (CustID, MetroAreaID) Values (@Customer_ID, @MetroAreaID)		

		Select CustID as UserID,email,FName as First_Name,1 as Updated from Customer where CustID = @Customer_ID
	
	END

	if (@@error <> 0)
		GOTO general_error

END
-- Account has been created,just send back info about account
else
	GOTO been_converted


COMMIT TRAN
RETURN(0)

general_error:
ROLLBACK TRAN
RAISERROR('143',16,1)
RETURN(1)

been_converted:
ROLLBACK TRAN
RAISERROR('142',16,1)
RETURN(1)
GO

GRANT EXECUTE ON [DNUserConvertAnon] TO ExecuteOnlyRole

GO
