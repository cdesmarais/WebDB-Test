if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserUpdate_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserUpdate_v2]
GO

CREATE Procedure dbo.DNUserUpdate_v2
 (
  @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @SortableFName nvarchar(255),
  @SortableLName nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @SendAnnouncements int,
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @State nvarchar(255),
  @ZipCode nvarchar(255),
  @Country char(2),
  @PhoneCountryID char(2),
  @DayPhone nvarchar(24),
  @MobilePhoneCountryID char(2) = null,
  @MObilePhone nvarchar(24) = null,
  @DefaultGeoID int,
  @DefaultRequests nvarchar(999),
  @BirthMonth int=null,
  @BirthYear int=null,
  @Salutation int,
  @TheDiningFormOptIn bit,
  @Hash varchar(128),
  @Salt varchar(128),
  @UserTokenTypeID  tinyint
 )
As

SET NOCOUNT ON
SET DATEFORMAT mdy
SET TRAN ISOLATION LEVEL READ UNCOMMITTED

if (isnull(ltrim(rtrim(@FirstName)),'') = '' or isnull(ltrim(rtrim(@LastName)), '') = '')
begin
	-- Reject updates that do not contain names
	select  @FirstName = isnull(ltrim(rtrim(@FirstName)), '<null>'), 
			@LastName = isnull(ltrim(rtrim(@LastName)), '<null>')
	RAISERROR('Update User Failed name is empty FirstName:%s LastName:%s',16,1, @FirstName, @LastName) --'Error update Customer.'
	RETURN(2)
end


declare @dup_UserID int

BEGIN TRAN

-- Ensure some other user doesn't already have this email address.
SELECT @dup_UserID= @UserID -- Set the default to the current ID.

SELECT @dup_UserID= CustID FROM Customer WHERE Email = @Email

if (@dup_UserID <> @UserID) GOTO dup_email

	
	UPDATE Customer
	SET FName = ltrim(rtrim(@FirstName)),LName = ltrim(rtrim(@LastName)),SFName = ltrim(rtrim(@SortableFName)),SLName = ltrim(rtrim(@SortableLName)),EMail = ltrim(rtrim(@Email)),
    	Address1 = @Address1,Address2 = @Address2,
    	City = @City,State = @State,Zip = @ZipCode,
    	Country = @Country,metroareaid = @DefaultGeoID,Special = @DefaultRequests,SendAnnouncements= ISNULL(@SendAnnouncements,SendAnnouncements),
	Salutation = @Salutation,BirthMonth = @BirthMonth,BirthYear = @BirthYear, DiningFormEmailOptIn=@TheDiningFormOptIn,
	SendPromoEmail = (case when (@SendAnnouncements is null) then SendPromoEmail when (@SendAnnouncements = 0 and SendAnnouncements = 1) then 0 else SendPromoEmail end)
	WHERE (CustID = @UserID)
	IF @@Error <> 0  goto general_error			
	

	--Update Phone numbers
	--parameters to this proc : @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, @IsCaller, @IsUpdate
	--@IsCaller =0 as this procedure is being called to update Customer Info
	--@IsUpdate = 1 as we are updating user record with phone information. 
	 Exec procUpdateUserPhoneDetails @UserID, @PhoneCountryID, @DayPhone, @MobilePhoneCountryID, @MobilePhone, 0, 1
	 
	 	-- Set Email Opt-In preferences
	IF (@SendAnnouncements IS NOT NULL)
	BEGIN
		IF EXISTS(SELECT CustID FROM UserOptIn WHERE CustID=@UserID)
			UPDATE UserOptIn
				SET Insider=@SendAnnouncements,DinersChoice=@SendAnnouncements,NewHot=@SendAnnouncements,RestaurantWeek=@SendAnnouncements,Promotional=@SendAnnouncements,SpotLight=@SendAnnouncements,Product=@SendAnnouncements,UpdatedDtUTC=getutcdate()
			WHERE CustID=@UserID
		ELSE
			IF EXISTS(SELECT CustID from Customer WHERE CustID=@UserID AND ConsumerType <> 8)  -- Anonymous users dont have email preferences
				INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID) 
					VALUES (@UserID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@DefaultGeoID)
	END
	
	
	
-- Insert CustomeToken 
	IF @Hash IS NOT NULL AND @Salt IS NOT NULL AND @UserTokenTypeID IS NOT NULL
	   AND NOT EXISTS (SELECT 1 FROM CustomerToken WHERE CustID = @UserID AND UserTokenTypeID = @UserTokenTypeID AND [Hash] = @Hash AND Salt = @Salt)	
	BEGIN	
		IF (@UserTokenTypeID <> 1)
		BEGIN
			declare @ErrorMsg as nvarchar(4000)	
			set @ErrorMsg = N'UserTokenTypeID should be 1'
			exec DNErrorAdd 1402, 'User_Update_v2', @ErrorMsg, 3
		END
		
		DELETE CustomerToken WHERE CustID = @UserID

		Insert into CustomerToken (CustID, Hash, Salt, UserTokenTypeID)
		values (@UserID, @Hash, @Salt, @UserTokenTypeID)
		
		IF @@Error <> 0  goto general_error			
	END	
	
	
COMMIT TRAN
RETURN(0)

dup_email:
ROLLBACK TRAN
RAISERROR('4',16,1)
RETURN(1)

general_error:
ROLLBACK TRAN
RAISERROR('7',16,1) --'Error update Customer.'
RETURN(2)

GO

GRANT EXECUTE ON [DNUserUpdate_v2] TO ExecuteOnlyRole

GO

