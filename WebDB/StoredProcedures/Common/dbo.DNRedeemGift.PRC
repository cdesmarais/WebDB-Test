if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRedeemGift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRedeemGift]
GO

CREATE Procedure dbo.DNRedeemGift
 (
  @UserID int = 0,
  @CallerID int = 0,
  @GiftID int,
  @Address1 nvarchar(40),
  @Address2 nvarchar(40),
  @City nvarchar(40),
  @State nvarchar(40),
  @ZipCode nvarchar(20),
  @Country nvarchar(40),
  @GiftAttributes nvarchar(25) = null,
  @UpdateProfileAddress int=0,
  @PointsLeft int output
 )
As
SET NOCOUNT ON
/*revised 10/27/2003 for new gift schema and data changes...*/
declare @GiftName nvarchar(255),@Description nvarchar(255)
declare @PointCost int,@PointsAvailable int,@User_ID int,@UisCaller int
set tran isolation level serializable
set xact_abort on

if ((@Country = 'US' or @Country = 'CA') and (@State = '' or @State = '--Select a State--'))
BEGIN
	Set @State = dbo.fStateByZip(@ZipCode,@Country)
	
END

begin tran
-- Get the user.
	select @PointsAvailable= -2
	
	if @UserID > 0
		BEGIN
		  (select @PointsAvailable= Points, 
			@CallerID = Null, 
			@User_ID = @UserID,
			@UisCaller = 0
			from Customer where CustID = @UserID)
		  
			if @UpdateProfileAddress > 0
			BEGIN
		        	Update Customer SET Address1 = @Address1,Address2 = @Address2,City = @City,State = @State,Zip = @ZipCode, Country = @Country where CustID = @UserID
                       	END
		END
	else
		BEGIN
		  (select @PointsAvailable= Points, 
			@CallerID = @CallerID, 
			@User_ID = Null,
			@UisCaller = 1
			from Caller where CallerID = @CallerID)
	
			if @UpdateProfileAddress > 0
			BEGIN
		        	Update Caller SET Address1 = @Address1,Address2 = @Address2,City = @City,State = @State,Zip = @ZipCode, Country = @Country where CallerID = @CallerID
                       	END

		END

	if @PointsAvailable < 0 Goto user_error
-- Get the Gift.
	select @PointCost= -1
	if ISNULL(@GiftAttributes,'NULL') = 'NULL'
 		BEGIN
 	  	  SELECT @GiftName= GiftName,@Description= GiftDesc,@PointCost= Points
 	  	  FROM Gift
 	  	  INNER JOIN GiftAttributes 
 	  	  ON  	 Gift.GiftID = GiftAttributes.GiftID
 	  	  WHERE (Gift.Active = 1) AND (Gift.GiftID = @GiftID) 
 		END
	ELSE --there are attributes
 		BEGIN
 		  SELECT @GiftName= GiftName,@Description= GiftDesc,@PointCost= GiftAttributes.Points
 		  FROM Gift
 		  INNER JOIN GiftAttributes ON
 		  Gift.GiftID = GiftAttributes.GiftID
 		  WHERE (GiftAttributes.Available = 1) AND (Gift.GiftID = @GiftID) AND 
		  (GiftAttributes.AttributeValue = @GiftAttributes) 
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
			 -- Exec Admin_AddPointsToCustomer @CustomerID = @User_ID,@IsCaller = 0,@Points =100,@Reason = 5
                          IF @@Error <> 0 goto error
 			end
 		If(@UserID = 0)
 			begin
 			  update Caller set Points= @PointsAvailable
 			  where CallerID = @CallerID
			 -- Exec Admin_AddPointsToCustomer @CustomerID = @CallerID,@IsCaller = 1,@Points =100,@Reason = 5
                          IF @@Error <> 0 goto error
 			end
		end
		
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

GRANT EXECUTE ON [DNRedeemGift] TO ExecuteOnlyRole

GO
