if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNConciergeAddCaller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNConciergeAddCaller]
GO


CREATE PROCEDURE dbo.DNConciergeAddCaller
 (
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @SFirstName nvarchar(255),
  @SLastName nvarchar(255),
  @login nvarchar(255),
  @Email nvarchar(255) = null,
  @Password nvarchar(255),
  @PhoneCountryID char(2),
  @DayPhone nvarchar(24),
  @DefaultGeoID int,
  @HotelID int,
  @Password_Question_ID int,
  @Password_Answer nvarchar(255)
 )
As
SET NOCOUNT ON
DECLARE @UserID int

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

-- Check that the login is not already in use.
If exists(select LoginName from caller where LoginName=@login) goto dup_email

-- Set a default email if no email provided
if coalesce(@Email, '') = '' and exists(Select Email from Company where CompanyID = @HotelID)
BEGIN
	Select @Email = Email from Company where CompanyID = @HotelID
END

-- Set a default metro if no metro provided
if @DefaultGeoID = 0 and exists(Select MetroAreaID from Company where CompanyID = @HotelID)
BEGIN
	Select @DefaultGeoID = MetroAreaID from Company where CompanyID = @HotelID
END

--Create the Caller row.
INSERT INTO Caller
	(FName,
	LName,
	SFName,
	SLName,
	EMail,
	metroareaid,
	CompanyID,
	PositionID,
	LoginName,
	PwdQuestionID,
	PwdAnswer,
	PartnerID,
	Points)
VALUES (
	@FirstName,
	@LastName,
	@SFirstName,
	@SLastName,
	@Email,
	@DefaultGeoID,
	@HotelID,
	2, -- Concierge
	@login,
	@Password_Question_ID,
	@Password_Answer,
	5, -- Concierge Partner
	0) -- 0 points
if (@@ERROR <> 0) GOTO dup_email

SELECT @UserID = scope_identity()

INSERT INTO CallerPhone 
	(PhoneTypeID,CallerID,PhoneCountryID,Phone, IsPrimary) 
	VALUES (6, @UserID,@PhoneCountryID, @DayPhone, 1)

if @@Error <> 0 GOTO general_error

	-- 	Set default Email Opt-In preferences
  	INSERT INTO UserOptIn (CallerID, MetroAreaID)
		VALUES(@UserID, @DefaultGeoID)

COMMIT TRAN

RETURN(0)

dup_email:
	ROLLBACK TRAN
	RAISERROR('116' ,16,2) --'That email address is already in use.'
	RETURN(1)
general_error:
	ROLLBACK TRAN
	RAISERROR('6' ,16,2) --'Error adding new Customer.'
	RETURN(2)

GO

GRANT EXECUTE ON [DNConciergeAddCaller] TO ExecuteOnlyRole

GO
