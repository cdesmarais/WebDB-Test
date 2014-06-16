if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SurveyShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SurveyShow]
GO

CREATE Procedure dbo.SurveyShow 
( 
 @RestaurantID int,
 @User_ID int,
 @Caller_ID int,
 @retval int  OUTPUT 
) 
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @weeksResponse int,@returnvalue bit,@CallerResponse int,@UserResponse int 

SET @returnvalue= 1 

--See if Restaurant can accept any more surveys 
Select @weeksResponse = count(RID) from SurveyResults where RID = @RestaurantID and DATEDIFF(wk,responseDate,getdate()) < 1 
if @weeksResponse > 4 
BEGIN 
        Set @returnvalue= 0 
END 

--See if user is in the database for this Restaurant 
if exists (Select CallerID from SurveyResults where RID = @RestaurantID and CallerID = @Caller_ID and @Caller_ID <> 0)

or exists (Select userid from SurveyResults where RID = @RestaurantID and userid = @User_ID and @User_ID <> 0)

BEGIN 
        Set @returnvalue= 0 
END 

--Has user taken survey more than 10 times? 
Select @CallerResponse = count(RID) from SurveyResults where CallerID = @Caller_ID and @Caller_ID <> 0 
Select @UserResponse = count(RID) from SurveyResults where userid = @User_ID and @User_ID <> 0 
if @CallerResponse > 9 or @UserResponse > 9 
BEGIN 
        Set @returnvalue= 0 
END 

Select @retval = @returnvalue
GO

GRANT EXECUTE ON [SurveyShow] TO ExecuteOnlyRole

GO
