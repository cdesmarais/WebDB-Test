if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Donate_Points]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Donate_Points]
GO






CREATE Procedure dbo.User_Donate_Points
 (
  @UserID int = 0,
  @CallerID int = 0,
  @Donation int,
  @Charity int,
  @PointsLeft int output
 )
As
/*revised for new schema 8/5/2003 --JD*/
SET NOCOUNT ON
declare @PointsAvailable int,@Caller_ID int,@User_ID int,@UisCaller int
set tran isolation level serializable
set xact_abort on
begin tran
-- Get the user.
	select @PointsAvailable= -2
	if @UserID > 0
		Begin
		  (select @PointsAvailable= Points,@Caller_ID = Null,@User_ID = @UserID from Customer where CustID = @UserID)
		End

	if @UserID = 0
		Begin
		  (select @PointsAvailable= Points,@Caller_ID = @CallerID,@User_ID = Null,@UisCaller = 1 from Caller where CallerID = @CallerID)
		End

	if @PointsAvailable < 0 Goto user_error

-- Log Redemption Claim and Deduct points from the user.
	if @Donation > @PointsAvailable
	  	Goto points_error
	else
		begin

		  Insert into Donations (UserFrom,CallerFrom,Charity,DonationAmount)
			VALUES (@User_ID,@Caller_ID,@Charity,@Donation)
		  
		  Exec Admin_AddPointsToCustomer @CustomerID = @Charity,@IsCaller = 1,@Points =@Donation,@Reason = 8

			IF @@Error <> 0 goto error
		
 			select @PointsAvailable= @PointsAvailable - @Donation
		
		Set @Donation = 0-@Donation

 		If(@UserID > 0)
 			begin
 			  --update Customer set Points= @PointsAvailable
 			  --where CustID = @UserID
			  Exec Admin_AddPointsToCustomer @CustomerID = @User_ID,@IsCaller = 0,@Points = @Donation,@Reason = 8
                          IF @@Error <> 0 goto error
 			end
 		If(@UserID = 0)
 			begin
 			  --update Caller set Points= @PointsAvailable
 			  --where CallerID = @CallerID
			  Exec Admin_AddPointsToCustomer @CustomerID = @CallerID,@IsCaller = 1,@Points = @Donation,@Reason = 8
                          IF @@Error <> 0 goto error
 			end
		end

		-- add 100 points for redeeming gift

commit tran
-- Set the return value.
select @PointsLeft= @PointsAvailable
Return(0)

error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('33',17,1)
         RETURN(1)
      END

user_error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('32',17,1)
         RETURN(2)
      END

points_error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('35',17,1)
         RETURN(4)
      END
GO

GRANT EXECUTE ON [User_Donate_Points] TO ExecuteOnlyRole

GO
