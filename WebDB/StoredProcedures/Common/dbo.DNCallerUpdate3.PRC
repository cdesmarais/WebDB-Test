if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCallerUpdate3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCallerUpdate3]
GO


CREATE PROCEDURE dbo.DNCallerUpdate3

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
@DiningFormEmailOptIn bit,
@Hash varchar(128),
@Salt varchar(128),
@UserTokenTypeID  TINYINT,
@retval int  = 0 OUTPUT 

As
SET NOCOUNT ON

if (ltrim(rtrim(@FirstName)) = '' or ltrim(rtrim(@LastName)) = '')
begin
	-- Reject updates that do not contain names
	select  @FirstName = isnull(ltrim(rtrim(@FirstName)), '<null>'), 
			@LastName = isnull(ltrim(rtrim(@LastName)), '<null>')
	RAISERROR('Update User Failed name is empty FirstName:%s LastName:%s',16,1, @FirstName, @LastName) --'Error update Customer.'
	RETURN(2)
end

BEGIN TRANSACTION

  declare @ErrorMsg as nvarchar(4000)	

  --check for dup email
  declare @n int
  Select @n = Count(CustID) from Customer where email = @Login
  if @n > 0 Goto email_error

  Select @n = Count(CallerID) from Caller where loginname = @Login and CallerID <> @CallerID 
  if @n > 0 Goto email_error

--get the original email and PositionID from Caller.  we will use this to update CallerCustomer
  Declare @OrigEmail varchar(255),@PositionID int,@OrigFName varchar(255),@OrigLName varchar(255)
  Select @OrigEmail = Email,@OrigFName = FName,@OrigLName = LName,@PositionID = PositionID from Caller where CallerID = @CallerID

		
 -- per TT 46378 we want to track whenever we try to insert logins and emails that don't match
	Declare @Enable int
	select @Enable = ValueInt from ValueLookup where LKey = 'Caller_Instrumentation' and LType = 'WEBSERVER'
	IF (@PositionID = 3 and @Enable = 1)
	BEGIN
		IF (@Login != @Email or @Email is null or @Login is null)
		BEGIN				
			set @ErrorMsg = N'Caller update login/email mismatch (callerid ' + cast(@CallerID as nvarchar(255)) + ') - login: ''' 
				+ cast(ISNULL(@Login,'NULL') as nvarchar(255)) 
				+ ''', email: ''' + cast(ISNULL(@Email,'NULL') as nvarchar(255)) + ''''
			exec DNErrorAdd 423, 'DNCallerUpdate3', @ErrorMsg, 2
		END
	END
	
	
--Do Caller and CallerPhone Updates
  UPDATE 	Caller set 
			FName = IsNull(@FirstName, FName),
			LName = IsNull(@LastName, LName),
			SFName = IsNull(@SortableFName, SFName),
			SLName = IsNull(@SortableLName, SLName),
			Email = IsNull(@Email, Email),
			Address1 = IsNull(@Address1, Address1),
			Address2 = IsNull(@Address2, Address2),
			City = IsNull(@City, City),
			State = IsNull(@State, State),
			Zip = IsNull(@ZipCode, Zip),
			Country = IsNull(@Country, Country),
			metroareaid = IsNull(@MetroAreaID, MetroAreaID),
			LoginName = IsNull(@Login, LoginName),
			SendAnnouncements = IsNull(@SendAnnouncements, SendAnnouncements),
			Salutation = IsNull(@Salutation, Salutation),
			BirthMonth = IsNull(@BirthMonth, BirthMonth),
			BirthYear = IsNull(@BirthYear, BirthYear),
			Notes = IsNull(@Notes, Notes),
			PwdQuestionID = (case when @PwdQuestionID = 0 then PwdQuestionID else @PwdQuestionID end), -- if it's 0 don't change it
			PwdAnswer = IsNull(@PwdAnswer, PwdAnswer), -- if it's null don't change it
			DiningFormEmailOptIn = IsNull(@DiningFormEmailOptIn, DiningFormEmailOptIn),
			SendPromoEmail = (case when (@SendAnnouncements is null) then SendPromoEmail  when (@SendAnnouncements = 0 and SendAnnouncements = 1) then 0 else SendPromoEmail end)
  WHERE CallerID = @CallerID
  IF @@Error <> 0  
     goto error

--Update the Diner record for the Admin account
 UPDATE 	CallerCustomer set 
			FName = IsNull(@FirstName, FName),
			LName = IsNull(@LastName, LName),
			SFName = IsNull(@SortableFName, SFName),
			SLName = IsNull(@SortableLName, SLName),
			Email = IsNull(@Email, Email)
 WHERE 		CallerID = @CallerID AND IsAdmin = 1

 IF @@Error <> 0  
     goto error  
  
  
  
		--Update Phone numbers
		--parameters to this proc : @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, @IsCaller, @IsUpdate
		--@IsCaller =1 as this procedure is being called from Caller
		--@IsUpdate = 1 as we are updating user record. 
		 Exec procUpdateUserPhoneDetails @CallerID, @PhoneCountryID, @Phone, @MobilePhoneCountryID, @MobilePhone, 1, 1
  
  IF @@Error <> 0  
     goto error
	 
	-- Set Email Opt-In preferences
	IF (@SendAnnouncements IS NOT NULL)
	BEGIN
		IF EXISTS(SELECT CallerID FROM UserOptIn WHERE CallerID=@CallerID)
			UPDATE UserOptIn
				SET Insider=@SendAnnouncements,DinersChoice=@SendAnnouncements,NewHot=@SendAnnouncements,RestaurantWeek=@SendAnnouncements,Promotional=@SendAnnouncements,SpotLight=@SendAnnouncements,Product=@SendAnnouncements,UpdatedDtUTC=getutcdate()
			WHERE CallerID=@CallerID
		ELSE
			INSERT INTO UserOptIn (CallerID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight, Product, MetroAreaID) 
				VALUES (@CallerID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements, @MetroAreaID)
	END
	
	IF @@Error <> 0  
		goto error		
		
	-- Insert CallerToken 
	IF @Hash IS NOT NULL AND @Salt IS NOT NULL AND @UserTokenTypeID IS NOT NULL
	   AND NOT EXISTS (SELECT 1 FROM CallerToken WHERE CallerID = @CallerID AND UserTokenTypeID = @UserTokenTypeID AND [Hash] = @Hash AND Salt = @Salt)	
	BEGIN
		IF (@UserTokenTypeID <> 1)
		BEGIN			
			set @ErrorMsg = N'UserTokenTypeID should be 1'
			exec DNErrorAdd 1402, 'User_Update_v2', @ErrorMsg, 3
		END	
	
		DELETE CallerToken WHERE CallerID = @CallerID

		Insert into CallerToken (CallerID, Hash, Salt, UserTokenTypeID)
		values (@CallerID, @Hash, @Salt, @UserTokenTypeID)
		
		IF @@Error <> 0  goto error			
	END
	

Select @retval = 1

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


GRANT EXECUTE ON [DNCallerUpdate3] TO ExecuteOnlyRole

GO


