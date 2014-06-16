if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Redeem_Gift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Redeem_Gift]
GO

CREATE Procedure dbo.Redeem_Gift
 (
  @UserID int = 0,
  @CallerID int = 0,
  @GiftID int,
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @State nvarchar(255),
  @ZipCode nvarchar(255),
  @Country nvarchar(255),
  @GiftAttributes nvarchar(255),
  @PointsLeft int output
 )
AS
/*revised 10/27/2003 for new gift schema and data changes...*/

declare @GiftName nvarchar(255),@Description nvarchar(255)
declare @PointCost int,@PointsAvailable int,@User_ID int,@UisCaller int
set tran isolation level serializable
set xact_abort on
begin tran
-- Get the user.
	select @PointsAvailable= -2
	if @UserID > 0
		Begin
		  (select @PointsAvailable= Points from Customer where CustID = @UserID)
		  (Select @CallerID = Null)
		  (Select @User_ID = @UserID)
		 -- Update Customer SET Address1 = @Address1,Address2 = @Address2,City = @City,State = @State,Zip = @ZipCode where CustID = @UserID
		  (Select @UisCaller = 0)
		End

	if @UserID = 0
		Begin
		  (select @PointsAvailable= Points from Caller where CallerID = @CallerID)
		  (Select @CallerID = @CallerID)
		  (Select @User_ID = Null)
		  (Select @UisCaller = 1)
		End

	if @PointsAvailable < 0 Goto user_error

-- Get the Gift.
	select @PointCost= -1
	if ISNULL(@GiftAttributes,'NULL') = 'NULL'
 		BEGIN
 	  	  SELECT @GiftName= GiftName,@Description= GiftDesc,@PointCost= Points
 	  	  FROM g
 	  	  INNER JOIN GiftAttributes 
 	  	  ON g.GiftID = GiftAttributes.GiftID
 	  	  WHERE (g.Active = 1) 
 	  	  AND (g.GiftID = @GiftID) 
 		END
	ELSE --there are attributes
 		BEGIN
 		  SELECT @GiftName= GiftName,@Description= GiftDesc,@PointCost= GiftAttributes.Points
 		  FROM GiftVW g
 		  INNER JOIN GiftAttributes 
 		  ON 	  g.GiftID = GiftAttributes.GiftID
 		  WHERE (GiftAttributes.Available = 1) 
 		  AND (g.GiftID = @GiftID) 
 		  AND  (GiftAttributes.AttributeValue = @GiftAttributes) 
 		END

	if @PointCost < 0 Goto gift_error
-- Log Redemption Claim and Deduct points from the user.
	if @PointCost > @PointsAvailable
	  	Goto points_error
	else
		begin
		  insert into GiftRedemption (CustID,CallerID,GiftID,Address1,Address2,City,State,Zip,Country,
		  RedemptionDate,PointsRedeemed,GiftAttributes)
		  Values (@User_ID,@CallerID,@GiftID, @Address1,@Address2,@City,@State,@ZipCode,@Country,getDate(),@PointCost,
		  @GiftAttributes)
IF @@Error <> 0 goto error

	
select @PointsAvailable= @PointsAvailable - @PointCost

If(@UserID > 0)
 			begin
 			  update Customer set Points= @PointsAvailable
 			  where CustID = @UserID
			  Exec Admin_AddPointsToCustomer @CustomerID = @User_ID,@IsCaller = 0,@Points =100,@Reason = 5
IF @@Error <> 0 goto error
 			end
If(@UserID = 0)
 			begin
 			  update Caller set Points= @PointsAvailable
 			  where CallerID = @CallerID
			  Exec Admin_AddPointsToCustomer @CustomerID = @CallerID,@IsCaller = 1,@Points =100,@Reason = 5
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

gift_error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('34',17,1)
         RETURN(3)
      END

points_error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('35',17,1)
         RETURN(4)
      END
GO

GRANT EXECUTE ON [Redeem_Gift] TO ExecuteOnlyRole

GO
