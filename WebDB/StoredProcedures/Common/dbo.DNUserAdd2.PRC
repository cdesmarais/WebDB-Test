if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserAdd2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserAdd2]
GO

CREATE Procedure dbo.DNUserAdd2
  (
	@Salutation int,
	@FirstName nvarchar(255),
	@LastName nvarchar(255),
	@SortableFirstName nvarchar(255),
	@SortableLastName nvarchar(255),
	@Email nvarchar(255),
	@Password nvarchar(255),
	@PhoneCountryID char(2),
	@DayPhone nvarchar(24),
	@MobilePhoneCountryID char(2) = null,
	@MobilePhone nvarchar(24) = null,
	@DefaultGeoID int,
	@ConsumerType int=null,
	@SendPromos bit,
	@Points int=300,
	@PartnerID int,
	@DiningFormFeedbackSetting bit,
	@SpecialRequest nvarchar(999),
	@retval int OUTPUT
  )

 
As
SET NOCOUNT ON


SET TRAN ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION MyTransaction
  
--***********************
--** No Points awarded for user creation
--***********************
set @Points = 0
  
DECLARE @UserID int
	SET @retval =  0

if @PartnerID = 0
BEGIN
	Set @PartnerID = 1
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = N'DNi18nUserAdd Had a Bad PartnerID ' +
		N' @Email: '+cast(ISNULL(@Email,'') as nvarchar(255))+ 
		N' @FirstName: '+ cast(ISNULL(@FirstName, '') as nvarchar(255)) +
		N' @LastName: '+ cast(ISNULL(@LastName, '') as nvarchar(255))
	exec DNErrorAdd 556, 'DNUserAdd2', @ErrorMsg, 1
END

  --check for duplicate email
    IF EXISTS(Select CustID from Customer where email = @Email and active = 0)
      	GOTO deactivated_Account
    IF EXISTS(Select CustID from Customer where email = @Email and ConsumerType = 8)
      	GOTO anon_userupdate
    IF EXISTS (Select 1 from Customer where email = @Email) 
      	GOTO dup_email


  -- Create the Customer and real Customer rows.
	INSERT INTO CallCusNextID (CustomerType) VALUES (1)

if (@@ERROR <> 0)
GOTO general_error
	SELECT @UserID = scope_identity()

 	INSERT INTO Customer
	(CustID,Salutation,FName,LName,SFName,SLName,EMail,metroareaid,SendAnnouncements,Points,ConsumerType,PwdQuestionID,PartnerID,DiningFormEmailOptIn,Special,SendPromoEmail)
	VALUES (@UserID,@Salutation,ltrim(rtrim(@FirstName)),ltrim(rtrim(@LastName)),
	ltrim(rtrim(@SortableFirstName)),ltrim(rtrim(@SortableLastName)),
	ltrim(rtrim(@Email)),
	@DefaultGeoID,@SendPromos,@Points,@ConsumerType,1,@PartnerID,@DiningFormFeedbackSetting,ltrim(rtrim(@SpecialRequest)),@SendPromos)
	
	IF (@ConsumerType <> 8)  -- No UserOptIn for Anonymous
		INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
			VALUES(@UserID,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@DefaultGeoID)

	--Insert Phone numbers
	--parameters to this proc : @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, @IsCaller, @IsUpdate
	--@IsCaller =0 as this procedure is being called to update Customer Info
	--@IsUpdate = 0 as we are inserting user record for the first time. 
	Exec procUpdateUserPhoneDetails @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, 0, 0

	
if (@UserID = 0) or (@@error <> 0)
	GOTO general_error

-- Set the return value and exit
SET @retval = @UserID

COMMIT TRAN MyTransaction

RETURN(0)

anon_userupdate:
	Select @UserID = CustID from Customer where email = @Email and ConsumerType = 8

	if @ConsumerType = 1
	BEGIN
	--************************
	--** Annonymous User Conversion
	--************************
	
		update Customer set 
		FName = ltrim(rtrim(@FirstName)),
		LName = ltrim(rtrim(@LastName)),
		SFName = ltrim(rtrim(@SortableFirstName)),
		SLName = ltrim(rtrim(@SortableLastName)),
		metroareaid = @DefaultGeoID,
		ConsumerType = @ConsumerType,
		Points = @Points,
		SendAnnouncements = @SendPromos,
		SendPromoEmail = @SendPromos,
		DiningFormEmailOptIn = @DiningFormFeedbackSetting
		where CustID = @UserID

		--********************************
		--** Log the Conversion
		--********************************
		Exec User_Convert_Consumer_Type @Customer_ID = @UserID,@Caller_ID = null,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = @ConsumerType

		--  Set User Email Opt-In Preferences		
		IF EXISTS(SELECT CustID FROM UserOptIn WHERE CustID=@UserID)
			UPDATE UserOptIn
				SET Insider=@SendPromos,DinersChoice=@SendPromos,NewHot=@SendPromos,RestaurantWeek=@SendPromos,Promotional=@SendPromos,SpotLight=@SendPromos,Product=@SendPromos,UpdatedDtUTC=getutcdate()
			WHERE CustID=@UserID
		ELSE
			INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID) 
				VALUES (@UserID,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@SendPromos,@DefaultGeoID)
	END
	ELSE
	BEGIN
		update Customer set 
			FName = ltrim(rtrim(@FirstName)),
			LName = ltrim(rtrim(@LastName)),
			SFName = ltrim(rtrim(@SortableFirstName)),
			SLName = ltrim(rtrim(@SortableLastName)),
			metroareaid = @DefaultGeoID,
			SendAnnouncements = @SendPromos,
			SendPromoEmail = @SendPromos
		where CustID = @UserID
	END	
	

	IF (@@ERROR <> 0) 
		GOTO general_error
	
	--********************************
	--** If user is no longer anonymous then convert all of previous annonymous history
	--** 0 Points for all Resos not pending
	--** NOTE: Promos associated with these resos will still be active
	--*******************************
	if (@ConsumerType <> 8)
	Update Reservation set ResPoints = 0 where CustID = @UserID and RStateID <> 1 and ResPoints <> 0

	-- Create the work and mobile phone rows.

	--Update Phone numbers
	--parameters to this proc : @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, @IsCaller, @IsUpdate
	--@IsCaller =0 as this procedure is being called to update Customer Info
	--@IsUpdate = 1 as we are updating user record with phone information. 
	 Exec procUpdateUserPhoneDetails @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, 0, 1
	

if (@@error <> 0)
	GOTO general_error

-- Set the return value and exit.
SELECT @retval= @UserID

COMMIT TRAN MyTransaction

RETURN(0)

-- Handle Error cases.

dup_email:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('4',16,1) --That email address is already in use.
	RETURN(3)

general_error:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('6',16,2) --Error adding new Customer.
	RETURN(5)

deactivated_Account:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('141',16,2) --Deactivated Account
	RETURN(5)
GO

GRANT EXECUTE ON [DNUserAdd2] TO ExecuteOnlyRole

GO

