if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Caller_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Caller_Add]
GO


CREATE PROCEDURE dbo.Admin_Concierge_Caller_Add
 (
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @SFirstName nvarchar(255),
  @SLastName nvarchar(255),
  @login nvarchar(255),
  @Email nvarchar(255) = null,
  @Country nvarchar(2) = null,
  @Phone nvarchar(24),
  @DefaultGeoID int,
  @HotelID int,
  @PartnerID int
 )
As
SET NOCOUNT ON
DECLARE @UserID int,@n int
SET DATEFORMAT mdy
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

-- Check that the email address is not already in use.
If exists(select LoginName from caller where LoginName=@login) goto dup_email

-- Check that the email address is not already in use.if exists(select LoginName from Caller where LoginName=@login) goto dup_email
if @Email is null and exists(Select Email from Company where CompanyID = @HotelID)
BEGIN
Select @Email = Email from Company where CompanyID = @HotelID
END

-- if country is null, set it to the country of the company
if (@Country is null)
BEGIN
SELECT @Country = Country FROM Company WHERE CompanyID = @HotelID
END

--Create the Caller row.
INSERT INTO Caller
 (FName,LName,SFName,SLName,EMail,metroareaid,CompanyID,PositionID,LoginName,PwdQuestionID,PartnerID,Points)
VALUES (@FirstName,@LastName,@SFirstName,@SLastName,@Email,@DefaultGeoID,@HotelID,2,@login,99,@PartnerID,0)

if (@@ERROR <> 0)
	GOTO dup_email

SELECT @UserID = scope_identity()

INSERT INTO CallerPhone
 (PhoneTypeID,CallerID,Phone, PhoneCountryID, IsPrimary)
VALUES (6,@UserID,@Phone, @Country, 1)

if @@Error <> 0
	GOTO general_error

--Add entry to GlobalPerson
INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(NULL, @UserID)
if @@Error <> 0
	GOTO general_error

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

GRANT EXECUTE ON [Admin_Concierge_Caller_Add] TO ExecuteOnlyRole

GO
