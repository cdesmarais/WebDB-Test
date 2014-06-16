if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Update]
GO

CREATE Procedure dbo.User_Update
 (
  @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @SendAnnouncements int,
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @State nvarchar(255),
  @ZipCode nvarchar(255),
  @Country char(2), -- TODO: Figurwe out contry code
  @DayPhone nvarchar(24),
  @DefaultGeoID int,
  @DefaultRequests nvarchar(999),
  @BirthMonth int=null,
  @BirthYear int=null,
  @Salutation int
 )
As

SET NOCOUNT ON
SET DATEFORMAT mdy
SET TRAN ISOLATION LEVEL SERIALIZABLE

declare @dup_UserID int


BEGIN TRAN

-- Ensure some other user doesn't already have this email address.
SELECT @dup_UserID= @UserID -- Set the default to the current ID.
SELECT @dup_UserID= CustID FROM Customer WHERE Email = @Email
if (@dup_UserID <> @UserID) GOTO dup_email

	UPDATE Customer
	SET FName = ltrim(rtrim(@FirstName)),LName = ltrim(rtrim(@LastName)),EMail = ltrim(rtrim(@Email)),
    	Address1 = @Address1,Address2 = @Address2,
    	City = @City,State = @State,Zip = @ZipCode,
    	Country = @Country,metroareaid = @DefaultGeoID,Special = @DefaultRequests,SendAnnouncements= ISNULL(@SendAnnouncements,SendAnnouncements),
		Salutation = @Salutation,BirthMonth = @BirthMonth,BirthYear = @BirthYear
	WHERE (CustID = @UserID)
	
	UPDATE CustomerPhone SET Phone= @DayPhone WHERE CustID = @UserID AND PhoneTypeID = 2 -- work
	
	IF (@SendAnnouncements IS NOT NULL)
		IF EXISTS(SELECT CustID from UserOptIn with (nolock) where CustID=@UserID and MetroAreaID = @DefaultGeoID)
			UPDATE UserOptin
				SET Insider = @SendAnnouncements, DinersChoice= @SendAnnouncements, NewHot= @SendAnnouncements, RestaurantWeek= @SendAnnouncements, Promotional= @SendAnnouncements, SpotLight= @SendAnnouncements,Product= @SendAnnouncements,UpdatedDtUTC=getutcdate()
			WHERE CustID = @UserID
			AND MetroAreaID =@DefaultGeoID
		ELSE
			IF EXISTS( SELECT CustID From Customer with (nolock)  WHERE CustID= @UserID AND ConsumerType <> 8)
				INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product, MetroAreaID)
					VALUES(@UserID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@DefaultGeoID)

COMMIT TRAN
RETURN(0)

dup_email:
ROLLBACK TRAN
RAISERROR('4',16,1)
RETURN(1)

GO

GRANT EXECUTE ON [User_Update] TO ExecuteOnlyRole

GO
