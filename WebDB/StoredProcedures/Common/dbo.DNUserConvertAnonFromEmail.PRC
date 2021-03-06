if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserConvertAnonFromEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserConvertAnonFromEmail]
GO


CREATE Procedure dbo.DNUserConvertAnonFromEmail
 (
  @UserEmail nvarchar(50),
  @newpassword nvarchar(50),
  @isAdmin int
  )
As

SET NOCOUNT ON

BEGIN TRAN

Declare @ConsumerType int,@HasBeenConverted int,@Caller_ID int,@Customer_ID int

Declare @RegPoints int
Set @RegPoints = 0
Set @HasBeenConverted = 0

Select @Customer_ID = CustID, @ConsumerType = ConsumerType from Customer where email = @UserEmail
if right(@UserEmail,8) = 'isAAUser'
BEGIN
	Set @HasBeenConverted = 1
END	

DECLARE @MetroAreaID INT

--See if accoount has been converted to regular user,if not convert

if exists(Select CustID from Customer where CustID = @Customer_ID and ConsumerType = 8) and @HasBeenConverted = 0

BEGIN

	select @MetroAreaID = MetroAreaID from Customer where CustID = @Customer_ID 

	--********************
	--** Update Customer set new consumeer type; assign reg points
	--********************
	Update Customer set ConsumerType = 1,points = @RegPoints,SendAnnouncements = 1 where CustID = @Customer_ID

	--********************************
	--** 0 Points for all Resos not pending
	--** NOTE: Promos associated with these resos will still be active
	--*******************************
	Update Reservation set ResPoints = 0 where CustID = @Customer_ID and RStateID <> 1 and ResPoints <> 0	
	
	if (@@error <> 0)
		GOTO general_error


	if @isAdmin = 1
	BEGIN
	--*************************
	--** Convert From Annon To Admin
	--*************************
	
		--********************************
		--** DeActivate Current Customer Record
		--** And Create a new Active Caller based on the Customer Record
		--** Update all Caller Related Data
		--********************************
		Exec DNChangeRealCustomerToAAUser @CustomerEmail = @UserEmail
		if (@@error <> 0)
			GOTO general_error
		Select @Caller_ID = CallerID from Caller where LoginName = @UserEmail

		--********************************
		--** Log the Conversion
		--********************************
		Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @Caller_ID,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

		if (@@error <> 0)
			GOTO general_error
			
		Select CallerID as UserID,email,FName as First_Name,1 as Updated from Caller where LoginName = @UserEmail
	
	
	END
	else
	BEGIN
	--*************************
	--** Convert from Annon to Normal User
	--*************************	

		--********************************
		--** Log the Conversion
		--********************************
		Exec User_Convert_Consumer_Type @Customer_ID = @Customer_ID,@Caller_ID = null,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

		if (@@error <> 0)
			GOTO general_error
			
		IF EXISTS(SELECT CustID FROM UserOptIn WHERE CustID=@Customer_ID and MetroAreaID=@MetroAreaID)
			UPDATE UserOptIn
				SET Insider=1,DinersChoice=1,NewHot=1,RestaurantWeek=1,Promotional=1,SpotLight=1,Product=1,UpdatedDtUTC=getutcdate()
			WHERE CustID=@Customer_ID
			AND MetroAreaID=@MetroAreaID
		ELSE
			INSERT INTO UserOptIn (CustID, MetroAreaID) VALUES (@Customer_ID, @MetroAreaID)	

		Select CustID as UserID,email,FName as First_Name,1 as Updated from Customer where CustID = @Customer_ID
	
	END

	if (@@error <> 0)
		GOTO general_error

END
-- Account has been created,just send back info about account
else
	GOTO been_converted


COMMIT TRAN
RETURN(0)

general_error:
ROLLBACK TRAN
RAISERROR('143',16,1)
RETURN(1)

been_converted:
ROLLBACK TRAN
RAISERROR('142',16,1)
RETURN(1)
GO

GRANT EXECUTE ON [DNUserConvertAnonFromEmail] TO ExecuteOnlyRole

GO
