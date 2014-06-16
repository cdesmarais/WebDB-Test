if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_CallerAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_CallerAdd]
GO

CREATE PROCEDURE dbo.AA_CallerAdd

(
@Points int,
@PositionID int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@Email nvarchar(255),
@MetroAreaID int,
@Password  nvarchar(255),
@PasswordQuestionID int,
@PartnerID int,
@Phone nvarchar(24),
@SendAnnouncements int,
@BirthMonth int=null,
@BirthYear int=null,
@Salutation int,
@retval  int OUTPUT 
)

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

  Declare @CallerID int
  
  --check for dup email (caller's must have unique LoginName)
  IF EXISTS (Select CallerID from Caller where LoginName = @email) Goto email_error

  IF EXISTS (Select CustID from Customer where email = @email and ConsumerType = 8) Goto anon_convert

  IF EXISTS(Select CustID from Customer where email = @email) Goto email_error

--Insert the caller
  Insert into Caller (Points,PositionID,FName,LName,Email,metroareaid,LoginName,PwdQuestionID, PartnerID,SendAnnouncements,BirthMonth,BirthYear,Salutation) values
                     (@Points,@PositionID,@FirstName,@LastName,@Email,@MetroAreaID,@Email,@PasswordQuestionID, @PartnerID,@SendAnnouncements,@BirthMonth,@BirthYear,@Salutation)
  IF @@Error <> 0  
    goto error
  
  Select @CallerID = scope_identity()
  Select @retval = @CallerID

  Insert into CallerPhone (PhoneTypeID,CallerID,Phone, IsPrimary) values (6, @CallerID,@Phone, 1)
  IF @@Error <> 0  
    goto error
  
  --Add entry to GlobalPerson
  INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(NULL, @CallerID)
  IF @@Error <> 0  
    goto error
	
  -- Set Email Opt-In preferences
  INSERT INTO UserOptIn (CallerID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
	VALUES(@CallerID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@MetroAreaID)

--If the Caller is an Admin,automatically make them a Diner

if @PositionID = 3 
   BEGIN
       declare @CustID int
   
       INSERT INTO CallCusNextID (CustomerType) VALUES (2)
       IF (@@ERROR <> 0) GOTO error

       Select @CustID = scope_identity()

       Insert into CallerCustomer (CustID,CallerID,FName,LName,Email,ContactPhone) 
       values (@CustID,@CallerID,@FirstName,@LastName,@Email,@Phone)

       Insert into CustomerPhone (PhoneTypeID,CustID,Phone, IsPrimary) values (5,@CustID,@Phone, 0)
       IF @@Error <> 0  
       goto error
   END

COMMIT TRANSACTION
Return(0)

error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('6',17,1)
         Set @retval = 0
         RETURN(1)
      END

email_error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('4',17,1)
         Set @retval = 0
         RETURN(1)
      END

anon_convert:
   BEGIN
	Declare @RealCustID int
	Select @RealCustID = CustID 
	from Customer 
	where email = @email and ConsumerType = 8
	
	update Customer Set
	FName = @FirstName,
	LName = @LastName,
	metroareaid = @MetroAreaID,
	PartnerID = @PartnerID,
	Salutation = @Salutation,
	ConsumerType = 1,points = 300,SendAnnouncements = 1
	where CustID = @RealCustID

	if (@@error <> 0)
		GOTO error

	Update CustomerPhone 
	set    Phone = @Phone
	where CustID = @RealCustID and PhoneTypeID = 2

 	Exec ChangeRealCustomerToAAUser @CustomerEmail = @email
	if (@@error <> 0)
		GOTO error
	
	Select @CallerID = CallerID from Caller where email = @email

	Update Reservation set ResPoints = 0 where CallerID = @CallerID and RStateID <> 1 and ResPoints <> 0

	Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @CallerID,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

	if (@@error <> 0)
		GOTO error

	Select @retval = CallerID from Caller where email = @email
	COMMIT TRANSACTION
	Return(0)
  END
GO

GRANT EXECUTE ON [AA_CallerAdd] TO ExecuteOnlyRole

GO
