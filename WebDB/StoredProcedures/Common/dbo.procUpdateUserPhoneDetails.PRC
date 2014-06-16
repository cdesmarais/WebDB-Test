if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procUpdateUserPhoneDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procUpdateUserPhoneDetails]
GO

CREATE Procedure dbo.procUpdateUserPhoneDetails
(
@UserID int,
@PhoneCountryID char(2),
@DayPhone nvarchar(24),
@MobilePhoneCountryID char(2),
@MobilePhone nvarchar(24),
@IsCaller bit,
@IsUpdate bit
)
AS
/*
This procedure will be called in 4 places 
1. Insert Customer record 
2. Update Customer record
3. Insert Caller record
4. Update Caller record

NOTE: This procedure handles data updates for anonymous users in a slightly different way than regular, or admin users. 
For anonymous users, we never delete mobile or day phone info if any one of the values are null. 
Because, they get to specify only one phone every time they make a reso on details page. 
So,We want to preserve both dayphone and mobile numbers for these users if they specify one. 
Once this user turns himself as regular or admin user, then we delete his phone number in case he leaves one of them blank.
*/

/* Data Initialization */
--Variables in the procedure
Declare @IsDayPhonePrimary bit,
		@IsMobilePrimary bit,
		@CleanPhoneInput nvarchar(24),
		@CleanMobileInput nvarchar(24),
		@ExistsUserPhoneID int,
		@ExistsUserMobilePhoneID int,
		@ExistsPrimaryPhoneTypeID int,
		@IsAnonymousUser bit


--clean user input
set @CleanPhoneInput = LTRIM(RTRIM(IsNull(@DayPhone, '')))
set @CleanMobileInput = LTRIM(RTRIM(IsNull(@MobilePhone, '')))

If(@CleanPhoneInput = '' AND @CleanMobileInput = '') GOTO DATAERROR

--Set Defaults
Set @IsDayPhonePrimary = 0
Set @IsMobilePrimary = 0
Set @ExistsUserPhoneID = null
Set @ExistsUserMobilePhoneID = null
Set @ExistsPrimaryPhoneTypeID = null
Set @IsAnonymousUser = 0 --Bit flag to store whether user is anon or regular user

--see if user home and mobile phone exists
--get these values if this an update.
if(@IsUpdate = 1)
Begin
	if(@IsCaller = 0)
		Begin
			Select @ExistsUserPhoneID = CustomerPhoneID  from CustomerPhone where custID = @userID and PhoneTypeID = 2
			Select @ExistsUserMobilePhoneID = CustomerPhoneID  from CustomerPhone where custID = @userID and PhoneTypeID = 4
			Select @ExistsPrimaryPhoneTypeID = PhoneTypeID from CustomerPhone where CustID = @UserID and IsPrimary = 1
			
			--see if user is anonymous	
			Select @IsAnonymousUser = (CASE WHEN ConsumerType = 8 THEN 1 ELSE 0 END) from Customer where CustID = @UserID
		End
	Else
		Begin
			Select @ExistsUserPhoneID = CallerPhoneID  from CallerPhone where CallerID = @userID and PhoneTypeID = 6
			Select @ExistsUserMobilePhoneID = CallerPhoneID  from CallerPhone where CallerID = @userID and PhoneTypeID = 4
			Select @ExistsPrimaryPhoneTypeID = PhoneTypeID from CallerPhone where CallerID = @UserID and IsPrimary = 1
		End
End

--Determine Primary Phone if this is new customer or caller. 
--If dayphone is not empty then its always set as primary phone
--if day phone is empty and mobile is not,then mobile is set as primary phon
	if(@CleanPhoneInput <> '') 
		Set @IsDayPhonePrimary  = 1 
	else if (@CleanMobileInput <> '')
		Set @IsMobilePrimary = 1

	--This is special scenario where Mobile phone exists and you are adding day phone.
	--if this condition is not added, it will create day phone and set it as primary based on above primary phone logic.
	--So to avoid two primaries, we check if primary already exists and both home and mobile phones are valid inputs
	--If Yes, then we overwrite @IsDayPhonePrimary  to 0.
	if(@ExistsPrimaryPhoneTypeID IS NOT NULL AND @CleanPhoneInput <> '' AND @CleanMobileInput <> '')
		Set @IsDayPhonePrimary  = 0 

	--If primary phone is already set AND User is anonymous, Reset variables that set primary phone type .
	if(@ExistsPrimaryPhoneTypeID IS NOT NULL AND (@IsAnonymousUser = 1))
	Begin
		Set @IsDayPhonePrimary  = 0
		Set @IsMobilePrimary = 0
	End
	

/* Data Initialization */

BEGIN TRANSACTION

--Customer info
if(@IsCaller = 0)
Begin
	--Insert home phone
	--insert for first time
	--insert if no home phone exists and mobile exists
	if(@ExistsUserPhoneID IS NULL AND @CleanPhoneInput <> '')
	Begin
			INSERT INTO CustomerPhone (PhoneTypeID,CustID,PhoneCountryID,Phone, IsPrimary)
			VALUES (2,@UserID,@PhoneCountryID,@DayPhone, @IsDayPhonePrimary)
			if (@@ERROR <> 0) GOTO General_error
	End
	
	--Insert mobile phone

	--insert for first time
	--insert if no MOBILE phone exists and HOME exists
	if(@ExistsUserMobilePhoneID IS NULL AND @CleanMobileInput <> '')
	Begin
			INSERT INTO CustomerPhone (PhoneTypeID,CustID,PhoneCountryID,Phone, IsPrimary)
			VALUES (4,@UserID,@MobilePhoneCountryID,@MobilePhone, @IsMobilePrimary)
			if (@@ERROR <> 0) GOTO General_error
	End
	
	if (@ExistsUserPhoneID IS NOT NULL)
	Begin
		if (@CleanPhoneInput <> '')
		Begin
			Update CustomerPhone set PhoneCountryID = @PhoneCountryID,	Phone = @DayPhone where CustomerPhoneID = @ExistsUserPhoneID
			if (@@ERROR <> 0) GOTO General_error
		End
		Else
		Begin
			
			if (@IsAnonymousUser = 0) --if the user is not anonymous
			Begin	
				--if phone number is empty, then delete the record
				Delete from CustomerPhone where CustomerPhoneID = @ExistsUserPhoneID
				if (@@ERROR <> 0) GOTO General_error
			
				--Update the next phone type to be primary _ here we just update the mobile phone type to be primary.
				-- User needs to have atleast one phone tied to their account and they cannot blank out both mobile and home.
				if(@ExistsUserMobilePhoneID is not null)
				Begin
					Update CustomerPhone set IsPrimary = 1 where CustomerPhoneID = @ExistsUserMobilePhoneID
					if (@@ERROR <> 0) GOTO General_error
				End
			End
		End
	End

	if (@ExistsUserMobilePhoneID > 0)
	Begin
		if (@CleanMobileInput <> '')
		Begin
			Update CustomerPhone set PhoneCountryID = @MobilePhoneCountryID, Phone = @MobilePhone where CustomerPhoneID = @ExistsUserMobilePhoneID
			if (@@ERROR <> 0) GOTO General_error
		End
		Else
		Begin
				if (@IsAnonymousUser = 0) --if the user is not anonymous
				Begin
					--if phone number is empty, then delete the record
					Delete from CustomerPhone where CustomerPhoneID = @ExistsUserMobilePhoneID
	
					if (@@ERROR <> 0) GOTO General_error
	
					--Update the next phone type to be primary _ here we just update the mobile phone type to be primary.
					-- User needs to have atleast one phone tied to their account and they cannot blank out both mobile and home.
					if(@ExistsUserPhoneID is not null)
					Begin
						Update CustomerPhone set IsPrimary = 1 where CustomerPhoneID = @ExistsUserPhoneID
						if (@@ERROR <> 0) GOTO General_error
					End
				End
		End
	End
End
--caller info
Else
Begin
	--Insert home phone
	--insert for first time
	--insert if no home phone exists and mobile exists
	if(@ExistsUserPhoneID IS NULL AND @CleanPhoneInput <> '')
	Begin
			INSERT INTO CallerPhone (PhoneTypeID,CallerID,PhoneCountryID,Phone, IsPrimary)
			VALUES (6, @UserID,@PhoneCountryID,@DayPhone, @IsDayPhonePrimary)
			
			if (@@ERROR <> 0) GOTO General_error
	End
	
	--Insert mobile phone
	--insert for first time
	--insert if no MOBILE phone exists and HOME exists
	if(@ExistsUserMobilePhoneID IS NULL AND @CleanMobileInput <> '')
	Begin
			INSERT INTO CallerPhone (PhoneTypeID,CallerID,PhoneCountryID,Phone, IsPrimary)
			VALUES (4,@UserID,@MobilePhoneCountryID,@MobilePhone, @IsMobilePrimary)
			if (@@ERROR <> 0) GOTO General_error
	End

	
	--Update HOME phone 
	if (@ExistsUserPhoneID > 0)
	Begin
		if (@CleanPhoneInput <> '')
		Begin
			Update CallerPhone set PhoneCountryID = @PhoneCountryID, Phone = @DayPhone where CallerPhoneID = @ExistsUserPhoneID
			if (@@ERROR <> 0) GOTO General_error
		End
		Else
		Begin
				--if phone number is empty, then delete the record
			    Delete from CallerPhone where CallerPhoneID = @ExistsUserPhoneID

				if (@@ERROR <> 0) GOTO General_error
				
				--Update the next phone type to be primary _ here we just update the mobile phone type to be primary.
				-- User needs to have atleast one phone tied to their account and they cannot blank out both mobile and home.
				if(@ExistsUserMobilePhoneID is not null)
				Begin
					Update CallerPhone set IsPrimary = 1 where CallerPhoneID = @ExistsUserMobilePhoneID
					if (@@ERROR <> 0) GOTO General_error
				End
		End
	End

	--Update mobile phone 
	if (@ExistsUserMobilePhoneID > 0)
	Begin
		if (@CleanMobileInput <> '')
		Begin
			Update CallerPhone set PhoneCountryID = @MobilePhoneCountryID,	Phone = @MobilePhone where CallerPhoneID = @ExistsUserMobilePhoneID
			if (@@ERROR <> 0) GOTO General_error
		End
		Else
		Begin
				--if phone number is empty, then delete the record
			    Delete from CallerPhone where CallerPhoneID = @ExistsUserMobilePhoneID

				if (@@ERROR <> 0) GOTO General_error
				
				--Update the next phone type to be primary _ here we just update the mobile phone type to be primary.
				-- User needs to have atleast one phone tied to their account and they cannot blank out both mobile and home.
			if(@ExistsUserPhoneID is not null)
			Begin
				Update CallerPhone set IsPrimary = 1 where CallerPhoneID = @ExistsUserPhoneID
				if (@@ERROR <> 0) GOTO General_error
			End
		End
	End	
End

COMMIT TRANSACTION
Return(0)


--Handle Error Cases
General_Error:
ROLLBACK TRANSACTION 
RAISERROR('Error Adding or Updating User Phone Information.',16,2) --Error adding user phone information.
RETURN(5)


DATAERROR:
RAISERROR(N'Cannot Insert or Update Phone Information as both Phone and Mobile Phone data is empty.', 16, 1)
RETURN(1)


GO

GRANT EXECUTE ON [procUpdateUserPhoneDetails] TO ExecuteOnlyRole

GO
