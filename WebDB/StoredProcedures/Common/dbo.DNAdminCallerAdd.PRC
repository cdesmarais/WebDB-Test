if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAdminCallerAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAdminCallerAdd]
GO


CREATE PROCEDURE dbo.DNAdminCallerAdd
--NOTE: for now this only saves credit card information for AAUsers (in the CallerCustomer table)...
/*created 10/3/2003*/
(
@Points int,
@PositionID int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@SortableFirstName nvarchar(255),
@SortableLastName nvarchar(255),
@Email nvarchar(255),
@MetroAreaID int,
@Password  nvarchar(255),
@PasswordQuestionID int,
@PartnerID int,
@PhoneCountryID char(2),
@Phone nvarchar(24),
@MobilePhoneCountryID char(2) = NULL,
@MobilePhone nvarchar(24) = NULL,
@SendAnnouncements int,
@BirthMonth int=null,
@BirthYear int=null,
@Salutation int,
@retval  int OUTPUT 
)
As
SET NOCOUNT ON

--**************************************************************************************
--** Begin OBSOLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR12 2011
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
  
  --** always award the registration points
  set @Points = 0
  
  if @PartnerID = 0
  BEGIN
  	set @PartnerID = 1
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = N'DNi18nAdminCallerAdd Had a Bad PartnerID ' +
		N' @Email: '+cast(ISNULL(@Email,'') as nvarchar(255))+ 
		N' @FirstName: '+ cast(ISNULL(@FirstName, '') as nvarchar(255)) +
		N' @LastName: '+cast(ISNULL(@LastName, '') as nvarchar(255))
	exec DNErrorAdd 556, 'DNAdminCallerAdd', @ErrorMsg, 1
  END

  --check for dup email
  IF EXISTS (Select CallerID from Caller where email = @email) Goto email_error
  IF EXISTS (Select CustID from Customer where email = @email and ConsumerType = 8) Goto anon_convert
  IF EXISTS(Select CustID from Customer where email = @email) Goto email_error
--Insert the caller
  Insert into Caller (Points,PositionID,FName,LName,SFName,SLName,Email,metroareaid,LoginName,PwdQuestionID, PartnerID,SendAnnouncements,BirthMonth,BirthYear,Salutation,DiningFormEmailOptIn) values
                     (@Points,@PositionID,@FirstName,@LastName,@SortableFirstName,@SortableLastName,@Email,@MetroAreaID,@Email,'99', @PartnerID,@SendAnnouncements,@BirthMonth,@BirthYear,@Salutation,1)
  IF @@Error <> 0  
    goto error
  
  Select @CallerID = scope_identity()
  Select @retval = @CallerID

  --Insert Phone numbers
  --parameters to this proc : @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, @IsCaller, @IsUpdate
  --@IsCaller =1 as this procedure is being called from Caller
  --@IsUpdate = 0 as we are inserting user record for the first time. 
   Exec procUpdateUserPhoneDetails @CallerID, @PhoneCountryID, @Phone, @MobilePhoneCountryID, @MobilePhone, 1, 0

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
       Insert into CallerCustomer (CustID,CallerID,FName,LName,SFName,SLName,Email,PhoneCountryID,ContactPhone,IsAdmin) 
       values (@CustID,@CallerID,@FirstName,@LastName,@SortableFirstName,@SortableLastName,@Email,@PhoneCountryID, @Phone,1)

       Insert into CustomerPhone (PhoneTypeID,CustID,PhoneCountryID,Phone) values (5,@CustID,@PhoneCountryID,@Phone)

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

	--*** Update Customer info, set RegPoints	
	update Customer Set
		FName = @FirstName,
		LName = @LastName,
		SFName = @SortableFirstName,
		SLName = @SortableLastName,
		metroareaid = @MetroAreaID,
		PartnerID = @PartnerID,
		Salutation = @Salutation,
		ConsumerType = 1,
		points = @Points,
		SendAnnouncements = 1
	where CustID = @RealCustID
	
	if (@@error <> 0)
		GOTO error

	 --Insert Phone numbers
  --parameters to this proc : @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, @IsCaller, @IsUpdate
  --@IsCaller = 0 as this procedure is being called to update customer info
  --@IsUpdate = 1 as we are updating customer info. 
   Exec procUpdateUserPhoneDetails @RealCustID, @PhoneCountryID, @Phone, @MobilePhoneCountryID, @MobilePhone, 0, 1


	--********************************
	--** DeActivate Current Customer Record
	--** And Create a new Active Caller based on the Customer Record
	--** Update all Caller Related Data
	--********************************
 	Exec DNChangeRealCustomerToAAUser @CustomerEmail = @email
	if (@@error <> 0)
		GOTO error
	
	--********************************
	--** 0 Points for all Resos not pending
	--** NOTE: Promos associated with these resos will still be active
	--********************************
	Select @CallerID = CallerID from Caller where email = @email
	Update Reservation set ResPoints = 0 where CallerID = @CallerID and RStateID <> 1 and ResPoints <> 0
		
	--********************************
	--** Log the Conversion
	--********************************
	Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @CallerID,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1
	if (@@error <> 0)
		GOTO error
		
	Select @retval = CallerID from Caller where email = @email
	COMMIT TRANSACTION
	Return(0)
  END
GO


GRANT EXECUTE ON [DNAdminCallerAdd] TO ExecuteOnlyRole

GO
