if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SurveyAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SurveyAdd]
GO

CREATE Procedure dbo.SurveyAdd
(
 @RestaurantID int,
 @User_ID int,
 @Caller_ID int,
 @Answer int,
 @ReservationID int,
 @Comments nvarchar(255) = null
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @weeksResponse int,@retval bit,@CallerResponse int,@UserResponse int

SET @retval= 1

--See if Restaurant can accept any more surveys
Select @weeksResponse = count(RID) from SurveyResults where RID = @RestaurantID and DATEDIFF(wk,ResponseDate,getdate()) < 1 
if @weeksResponse > 5
BEGIN
	Set @retval= 0
END

--See if user is in the database for this restaurant

if exists (Select CallerID from SurveyResults where RID = @RestaurantID and CallerID = @Caller_ID and @Caller_ID <> 0)
or exists (Select userid from SurveyResults where RID = @RestaurantID and userid = @User_ID and @User_ID <> 0)
BEGIN
	Set @retval= 0
END

--Has user taken survey more than 10 times?
Select @CallerResponse = count(RID) from SurveyResults where CallerID = @Caller_ID and @Caller_ID <> 0
Select @UserResponse = count(RID) from SurveyResults where userid = @User_ID and @User_ID <> 0
if @CallerResponse > 10 or @UserResponse > 10
BEGIN
	Set @retval= 0
END
if @retval = 1
BEGIN
	Insert into SurveyResults (userid,CallerID,ResponseDate,RID,AnswerID,ResID,Comments)
	VALUES
	(@User_ID,@Caller_ID,getdate(),@RestaurantID,@Answer,@ReservationID,@Comments)


	If(@User_ID > 0)
	begin
		Exec Admin_AddPointsToCustomer @CustomerID = @User_ID,@IsCaller = 0,@Points =10,@Reason = 6
	end
	If(@User_ID = 0)
	begin
		Exec Admin_AddPointsToCustomer @CustomerID = @Caller_ID,@IsCaller = 1,@Points =10,@Reason = 6
	end


END
GO

GRANT EXECUTE ON [SurveyAdd] TO ExecuteOnlyRole

GO
