if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Add]
GO

CREATE Procedure dbo.User_Add
 (
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @State nvarchar(255),
  @ZipCode nvarchar(255),
  @Country char(2),-- TODO: Figurwe out contry code
  @DayPhone nvarchar(24),
  @FaxPhone nvarchar(24),
  @DefaultGeoID int,
  @DefaultRequests nvarchar(999),
  @PartnerID int,
  @PasswordQuestionID int,
  @SendAnnouncements bit,
  @Points int=300,
  @BirthMonth int=null,
  @BirthYear int=null,
  @Salutation int=null,
  @ConsumerType int=null,
  @retval int OUTPUT
 )
/*revised for new schema 8/4/2003 --JD
Note: changes were made to CallCustNextID table to remove constraint and change datatype of customertypeid...*/
As
SET NOCOUNT ON
DECLARE 
@UserID int
,@n int
,@TranName nvarchar(20)

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION MyTransaction

-- 1/6/2005 CK - If this is an xml partner, treat them as an anonymous user
if exists(Select PartnerID from Partner where PartnerID = @PartnerID and XMLFlag = 1)
BEGIN
	Set @ConsumerType = 8
	Set @Points = 0
END

 --check for dup email
IF EXISTS (Select CallerID from Caller where email = @email) 
    GOTO dup_email
IF EXISTS(Select CustID from Customer where email = @email and active = 0)
    GOTO deactivated_Account
IF EXISTS(Select CustID from Customer where email = @email and ConsumerType = 8)
    GOTO anon_userupdate
IF EXISTS(Select CustID from Customer where email = @email)
    GOTO dup_email

 -- Create the Customer and real Customer rows.

if @Salutation = 6
BEGIN
	Set @Salutation = null
END

if @PartnerID = 27
BEGIN
	Set @DefaultGeoID = 58
END



if @PartnerID != 1
BEGIN
	Set @SendAnnouncements = 0
END

	INSERT INTO CallCusNextID (CustomerType) VALUES (1)
	SELECT @UserID = scope_identity()

	INSERT INTO Customer
	
	(CustID
	,FName
	,LName
	,EMail
	,Address1
	,Address2
	,City
	,State
	,Zip
	,Country
	,metroareaid
	,Special
	,PartnerID
	,PwdQuestionID,SendAnnouncements,Points,BirthMonth,BirthYear,Salutation,ConsumerType)
	VALUES (@UserID,ltrim(rtrim(@FirstName)),ltrim(rtrim(@LastName)),ltrim(rtrim(@Email)),@Address1,
 	@Address2,@City,@State,@ZipCode,@Country,@DefaultGeoID,
 	@DefaultRequests,@PartnerID,@PasswordQuestionID,@SendAnnouncements,@Points,@BirthMonth,@BirthYear,@Salutation,@ConsumerType)
	
	IF (@@ERROR <> 0) 
	GOTO general_error

--SELECT @UserID = scope_identity()

	--Add entry to GlobalPerson
	INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(@UserID, NULL)
	IF (@@ERROR <> 0) 
	GOTO general_error

-- Create the work and fax phone rows.
	INSERT INTO CustomerPhone 	(PhoneTypeID,CustID,Phone, IsPrimary)
	VALUES (2,@UserID,@DayPhone, 1)

IF @FaxPhone IS NOT NULL
	INSERT INTO CustomerPhone 	(PhoneTypeID,CustID,Phone, IsPrimary)
    VALUES (5,@UserID,@FaxPhone, 0)
    
if (@UserID = 0) or (@@error <> 0)
	GOTO general_error
	
	IF (@ConsumerType <> 8)  -- Set Email Opt-In preferences
	INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
		VALUES(@UserID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@DefaultGeoID)

-- Set the return value and exit.
SELECT @retval= @UserID

COMMIT TRAN

RETURN(0)


anon_userupdate:
	
	if @Salutation = 6
	BEGIN
		Set @Salutation = null
	END
	Select @UserID = CustID from Customer where email = @email and ConsumerType = 8

	if @ConsumerType = 1
	BEGIN
		update Customer set 
		FName = ltrim(rtrim(@FirstName)),
		LName = ltrim(rtrim(@LastName)),
		metroareaid = @DefaultGeoID,
		Special = @DefaultRequests,
		PartnerID = @PartnerID,
		ConsumerType = @ConsumerType,
		Salutation = @Salutation
		where CustID = @UserID
		
		IF EXISTS(Select CustID FROM UserOptIn with (nolock) WHERE CustID=@UserID And MetroAreaID = @DefaultGeoID)
			UPDATE UserOptIn
				SET Insider=@SendAnnouncements,DinersChoice=@SendAnnouncements,NewHot=@SendAnnouncements,RestaurantWeek=@SendAnnouncements,Promotional=@SendAnnouncements,SpotLight=@SendAnnouncements,Product=@SendAnnouncements,UpdatedDtUTC=getutcdate()
			WHERE CustID=@UserID
			AND MetroAreaID = @DefaultGeoID
		ELSE
			INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID) 
				VALUES (@UserID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@DefaultGeoID)
	END
	ELSE
	BEGIN
		update Customer set 
		FName = ltrim(rtrim(@FirstName)),
		LName = ltrim(rtrim(@LastName)),
		metroareaid = @DefaultGeoID,
		Special = @DefaultRequests,
		PartnerID = @PartnerID,
		Salutation = @Salutation
		where CustID = @UserID
	END	
	

	IF (@@ERROR <> 0) 
		GOTO general_error

	Update Reservation set ResPoints = 0 where CustID = @UserID and RStateID <> 1

-- Create the work and fax phone rows.
	Update CustomerPhone set 
	Phone = @DayPhone
	where CustID = @UserID and IsPrimary = 1
if (@@error <> 0)
	GOTO general_error

-- Set the return value and exit.
SELECT @retval= @UserID

COMMIT TRAN

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

GRANT EXECUTE ON [User_Add] TO ExecuteOnlyRole

GO
